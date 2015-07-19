$fuel_settings = parseyaml($astute_settings_yaml)
$all_nodes = $fuel_settings['nodes']
$nsdb_nodes = filter_nodes($all_nodes, 'role', 'nsdb')
$zoo_ips = generate_api_zookeeper_ips($nsdb_nodes)
$m_version = $fuel_settings['midonet']['version']

# MidoNet api manifest
class {'::midonet::repository':
  midonet_repo => "http://repo.midonet.org/midonet/${m_version}/RHEL"
} ->

class {'::midonet::midonet_api':
  zk_servers           => $zoo_ips,
  keystone_auth        => true,
  keystone_host        => $::fuel_settings['management_vip'],
  keystone_admin_token => $::fuel_settings['keystone']['admin_token'],
  api_ip               => $::fuel_settings['public_vip'],
  api_port             => '8081'
}

# HA proxy configuration

Openstack::Ha::Haproxy_service {
  server_names        => filter_hash($::controllers, 'name'),
  ipaddresses         => filter_hash($::controllers, 'internal_address'),
  public_virtual_ip   => $::fuel_settings['public_vip'],
  internal_virtual_ip => $::fuel_settings['management_vip'],
}

#TODO(haproxy call)

# Open ports

firewall {'502 Midonet api':
  port => '8081',
  proto => 'tcp',
  action => 'accept',
}
