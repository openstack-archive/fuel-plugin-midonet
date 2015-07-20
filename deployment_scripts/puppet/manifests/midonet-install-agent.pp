$fuel_settings = parseyaml($astute_settings_yaml)
$all_nodes = $fuel_settings['nodes']
$nsdb_nodes = filter_nodes($all_nodes, 'role', 'nsdb')
$zoo_ips = generate_api_zookeeper_ips($nsdb_nodes)
$cass_hash = nodes_to_hash($nsdb_nodes, 'name', 'internal_address')
$api_ip = $::fuel_settings['management_vip']

$m_version = $::fuel_settings['midonet']['version']
$username = $fuel_settings['access']['user']
$password = $fuel_settings['access']['password']
$tenant_name = $fuel_settings['access']['tenant']

$ovsdb_service_name = $operatingsystem ? {
  'CentOS' => 'openvswitch',
  'CentOS' => 'openvswitch-switch'
}

$openvswitch_package_neutron = $operatingsystem ? {
  'CentOS' => 'openstack-neutron-openvswitch',
  'Ubuntu' => 'neutron-plugin-openvswitch-agent'
}

$openvswitch_package = $operatingsystem ? {
  'CentOS' => 'openvswitch',
  'Ubuntu' => 'openvswitch-switch'
}

$mido_repo = $operatingsystem ? {
  'CentOS' => "http://repo.midonet.org/midonet/${m_version}/RHEL",
  'Ubuntu' => "http://repo.midonet.org/midonet/${m_version}"
}

# MidoNet api manifest
class {'::midonet::repository':
  midonet_repo => $mido_repo
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
  cassandra_seeds => values($cass_hash)
} ->

class {'::midonet::midonet_cli':
  api_endpoint => "http://${api_ip}:8081/midonet-api",
  username     => $username,
  password     => $password,
  tenant_name  => $tenant_name
}
