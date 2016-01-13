# Neutron data
$amqp_port             = '5673'
$rabbit_hash           = hiera('rabbit_hash', {})
$service_endpoint      = hiera('management_vip')
$neutron_config        = hiera('quantum_settings')
$neutron_db_password   = $neutron_config['database']['passwd']
$neutron_user_password = $neutron_config['keystone']['admin_password']

# Neutron plugin data
$access_data      = hiera_hash('access')
$username         = $access_data['user']
$password         = $access_data['password']
$tenant_name      = $access_data['tenant']

class {'::neutron':
  verbose                 => false,
  debug                   => false,
  use_syslog              => false,
  log_facility            => 'LOG_USER',
  base_mac                => 'fa:16:3e:00:00:00',
  core_plugin             => 'neutron.plugins.midonet.plugin.MidonetPluginV2',
  service_plugins         => [],
  allow_overlapping_ips   => true,
  mac_generation_retries  => 32,
  dhcp_lease_duration     => 600,
  dhcp_agents_per_network => 2,
  report_interval         => 5,
  rabbit_user             => $rabbit_hash['user'],
  rabbit_host             => ['localhost'],
  rabbit_hosts            => split(hiera('amqp_hosts', ''), ','),
  rabbit_port             => '5672',
  rabbit_password         => $rabbit_hash['password'],
  kombu_reconnect_delay   => '5.0',
  network_device_mtu      => undef,
}

class {'::neutron::plugins::midonet':
  midonet_api_ip    => $service_endpoint,
  midonet_api_port  => '8081',
  keystone_username => $username,
  keystone_password => $password,
  keystone_tenant   => $tenant_name
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
}

class { '::neutron::agents::dhcp':
  debug                    => false,
  interface_driver         => 'neutron.agent.linux.interface.MidonetInterfaceDriver',
  dhcp_driver              => 'midonet.neutron.agent.midonet_driver.DhcpNoOpDriver',
  enable_isolated_metadata => true,
  enabled                  => true,
}
