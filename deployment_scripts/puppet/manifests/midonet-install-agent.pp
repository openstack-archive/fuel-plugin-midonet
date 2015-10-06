$fuel_settings = parseyaml($astute_settings_yaml)
$all_nodes = $fuel_settings['nodes']
$nsdb_nodes = filter_nodes($all_nodes, 'role', 'nsdb')
$zoo_ips = generate_api_zookeeper_ips($nsdb_nodes)
$cass_hash = nodes_to_hash($nsdb_nodes, 'name', 'internal_address')
$api_ip = $::fuel_settings['management_vip']

$m_version = 'v2015.06'
$username = $fuel_settings['access']['user']
$password = $fuel_settings['access']['password']
$tenant_name = $fuel_settings['access']['tenant']

$midonet_settings = $fuel_settings['midonet-fuel-plugin']
$mem = $midonet_settings['mem']
$mem_version = $midonet_settings['mem_version']
$mem_user = $midonet_settings['mem_repo_user']
$mem_password = $midonet_settings['mem_repo_password']

$ovsdb_service_name = $operatingsystem ? {
  'CentOS' => 'openvswitch',
  'Ubuntu' => 'openvswitch-switch'
}

$openvswitch_package_neutron = $operatingsystem ? {
  'CentOS' => 'openstack-neutron-openvswitch',
  'Ubuntu' => 'neutron-plugin-openvswitch-agent'
}

$openvswitch_package = $operatingsystem ? {
  'CentOS' => 'openvswitch',
  'Ubuntu' => 'openvswitch-switch'
}

if $mem {
  $mido_repo = $operatingsystem ? {
    'CentOS' => "http://${mem_user}:${mem_password}@yum.midokura.com/repo/${mem_version}/stable/RHEL",
    'Ubuntu' => "http://${mem_user}:${mem_password}@apt.midokura.com/midonet/${mem_version}/stable"
  }
} else {
  $mido_repo = $operatingsystem ? {
    'CentOS' => "http://repo.midonet.org/midonet/${m_version}/RHEL",
    'Ubuntu' => "http://repo.midonet.org/midonet/${m_version}"
  }
}

class {'::midonet::repository':
  midonet_repo       => $mido_repo,
  manage_distro_repo => false,
  openstack_release  => 'juno'
} ->

service {$ovsdb_service_name:
  ensure => stopped,
  enable => false
} ->

package {$openvswitch_package_neutron:
  ensure => absent
} ->

package {$openvswitch_package:
  ensure => absent
} ->

class {'::midonet::midonet_agent':
  zk_servers      => $zoo_ips,
  cassandra_seeds => values($cass_hash),
  require         => Class['::midonet::repository']
} ->

class {'::midonet::midonet_cli':
  api_endpoint => "http://${api_ip}:8081/midonet-api",
  username     => $username,
  password     => $password,
  tenant_name  => $tenant_name,
  require      => Class['::midonet::repository']
}
