# Extract data from hiera
$network_metadata     = hiera_hash('network_metadata')
$controllers_map      = get_nodes_hash_by_roles($network_metadata, ['controller', 'primary-controller'])
$controllers_mgmt_ips = get_node_to_ipaddr_map_by_network_role($controllers_map, 'management')
$nsdb_hash            = get_nodes_hash_by_roles($network_metadata, ['nsdb'])
$nsdb_mgmt_ips        = get_node_to_ipaddr_map_by_network_role($nsdb_hash, 'management')
$zoo_ips_hash         = generate_api_zookeeper_ips(values($nsdb_mgmt_ips))
$management_vip       = hiera('management_vip')
$public_vip           = hiera('public_vip')
$keystone_data        = hiera_hash('keystone')
$access_data          = hiera_hash('access')
$public_ssl_hash      = hiera('public_ssl')

class {'::midonet::midonet_api':
  zk_servers           => $zoo_ips_hash,
  keystone_auth        => true,
  keystone_host        => $management_vip,
  keystone_admin_token => $keystone_data['admin_token'],
  keystone_tenant_name => $access_data['tenant'],
  bind_address         => $::ipaddress_br_mgmt,
  api_ip               => $public_vip,
  api_port             => '8081',
}

# HA proxy configuration
Haproxy::Service        { use_include   => true }
Haproxy::Balancermember { use_include => true }

Openstack::Ha::Haproxy_service {
  server_names        => keys($controllers_mgmt_ips),
  ipaddresses         => values($controllers_mgmt_ips),
  public_virtual_ip   => $public_vip,
  internal_virtual_ip => $management_vip
}

openstack::ha::haproxy_service { 'midonetapi':
  order                  => 199,
  listen_port            => 8081,
  balancermember_port    => 8081,
  define_backups         => true,
  before_start           => true,
  public                 => true,
  haproxy_config_options => {
    'balance'        => 'roundrobin',
    'option'         => ['httplog'],
  },
  balancermember_options => 'check',
}

exec { 'haproxy reload':
  command   => 'export OCF_ROOT="/usr/lib/ocf"; (ip netns list | grep haproxy) && ip netns exec haproxy /usr/lib/ocf/resource.d/fuel/ns_haproxy reload',
  path      => '/usr/bin:/usr/sbin:/bin:/sbin',
  logoutput => true,
  provider  => 'shell',
  tries     => 10,
  try_sleep => 10,
  returns   => [0, ''],
}

Haproxy::Listen <||> -> Exec['haproxy reload']
Haproxy::Balancermember <||> -> Exec['haproxy reload']

class { 'firewall': }

firewall {'502 Midonet api':
  port => '8081',
  proto => 'tcp',
  action => 'accept',
}
