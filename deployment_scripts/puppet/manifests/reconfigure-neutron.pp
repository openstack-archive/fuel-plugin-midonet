$fuel_settings = parseyaml($astute_settings_yaml)
$address = hiera('management_vip')
$m_version = $fuel_settings['midonet']['version']
# amqp settings
$controllers                    = hiera('controllers')
$controller_internal_addresses  = nodes_to_hash($controllers,'name','internal_address')
$controller_nodes               = ipsort(values($controller_internal_addresses))
$internal_address = hiera('internal_address')
if $internal_address in $controller_nodes {
  # prefer local MQ broker if it exists on this node
  $amqp_nodes = concat(['127.0.0.1'], fqdn_rotate(delete($controller_nodes, $internal_address)))
} else {
  $amqp_nodes = fqdn_rotate($controller_nodes)
}

$amqp_port = '5673'
$amqp_hosts = inline_template("<%= @amqp_nodes.map {|x| x + ':' + @amqp_port}.join ',' %>")
$rabbit_hash = hiera('rabbit_hash', {})
$service_endpoint = hiera('management_vip')
$neutron_config        = hiera('quantum_settings')
$neutron_db_password   = $neutron_config['database']['passwd']
$neutron_user_password = $neutron_config['keystone']['admin_password']

ensure_resource('file', '/etc/neutron/plugins/midonet', {
  ensure => directory,
  owner  => 'root',
  group  => 'neutron',
  mode   => '0640'}
)

neutron_plugin_midonet {
  'MIDONET/midonet_uri':  value => "http://${address}:8081/midonet-api";
  'MIDONET/username':     value => 'admin';
  'MIDONET/password':     value => 'admin';
  'MIDONET/project_id':   value => 'admin';
} ->

package {'python-neutron-plugin-midonet':
  ensure => present
}

if $::osfamily == 'Debian' {
    file_line { '/etc/default/neutron-server:NEUTRON_PLUGIN_CONFIG':
      path    => '/etc/default/neutron-server',
      match   => '^NEUTRON_PLUGIN_CONFIG=(.*)$',
      line    => "NEUTRON_PLUGIN_CONFIG=/etc/neutron/plugins/midonet/midonet.ini",
      notify  => Service['neutron-server'],
  }
}

# In RH, this link is used to start Neutron process but in Debian, it's used only
# to manage database synchronization.
if defined(File['/etc/neutron/plugin.ini']) {
  File <| path == '/etc/neutron/plugin.ini' |> { target => '/etc/neutron/plugins/midonet/midonet.ini' }
}
else {
  file {'/etc/neutron/plugin.ini':
    ensure  => link,
    target  => '/etc/neutron/plugins/midonet/midonet.ini'
  }
}

class {'::neutron':
  verbose                 => false,
  debug                   => false,
  use_syslog              => false,
  log_facility            => 'LOG_USER',
  base_mac                => 'fa:16:3e:00:00:00',
  core_plugin             => 'midonet.neutron.plugin.MidonetPluginV2',
  service_plugins         => [],
  allow_overlapping_ips   => true,
  mac_generation_retries  => 32,
  dhcp_lease_duration     => 600,
  dhcp_agents_per_network => 2,
  report_interval         => 5,
  rabbit_user             => $rabbit_hash['user'],
  rabbit_host             => ['localhost'],
  rabbit_hosts            => [$amqp_hosts],
  rabbit_port             => '5672',
  rabbit_password         => $rabbit_hash['password'],
  kombu_reconnect_delay   => '5.0',
  network_device_mtu      => undef,
}

class { '::neutron::server':
  sync_db       => $primary_controller ? {true => 'primary', default => 'slave'},
  auth_host     => $service_endpoint,
  auth_port     => '35357',
  auth_protocol => 'http',
  auth_password => $neutron_user_password,
  auth_tenant   => 'services',
  auth_user     => 'neutron',
  auth_uri      => "http://${service_endpoint}:35357/v2.0",

  database_retry_interval => 2,
  database_connection     => "mysql://neutron:${neutron_db_password}@${service_endpoint}/neutron?&read_timeout=60",
  database_max_retries    => -1,

  agent_down_time => 15,

  api_workers => min($::processorcount + 0, 50 + 0),
  rpc_workers => 0,
} ->

class { '::neutron::agents::dhcp':
  debug            => false,
  interface_driver => 'neutron.agent.linux.interface.MidonetInterfaceDriver',
  dhcp_driver      => 'midonet.neutron.agent.midonet_driver.DhcpNoOpDriver',
  enabled          => true,
}
