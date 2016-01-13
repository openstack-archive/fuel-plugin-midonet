# Extract data from hiera
$network_metadata = hiera_hash('network_metadata')
$neutron_config   = hiera_hash('neutron_config')
$segmentation_type = $neutron_config['L2']['segmentation_type']
$nsdb_hash        = get_nodes_hash_by_roles($network_metadata, ['nsdb'])
$nsdb_mgmt_ips    = get_node_to_ipaddr_map_by_network_role($nsdb_hash, 'management')
$zoo_ips_hash     = generate_api_zookeeper_ips(values($nsdb_mgmt_ips))
$cass_ips         = values($nsdb_mgmt_ips)
$api_ip           = hiera('management_vip')
$access_data      = hiera_hash('access')
$username         = $access_data['user']
$password         = $access_data['password']
$tenant_name      = $access_data['tenant']

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
  zk_servers      => $zoo_ips_hash,
  cassandra_seeds => $cass_ips
} ->

class {'::midonet::midonet_cli':
  api_endpoint => "http://${api_ip}:8081/midonet-api",
  username     => $username,
  password     => $password,
  tenant_name  => $tenant_name,
}

# Firewall rule to allow the udp port used for vxlan tunnelling of overlay
#  traffic from midolman hosts to other midolman hosts.

if $segmentation_type =='tun' {
  firewall {'6677 vxlan port':
    port   => '6677',
    proto  => 'udp',
    action => 'accept',
  }
}

