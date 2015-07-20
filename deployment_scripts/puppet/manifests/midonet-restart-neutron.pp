$fuel_settings = parseyaml($astute_settings_yaml)
$access_hash = hiera('access', {})
$keystone_admin_tenant = $access_hash[tenant]
$neutron_settings = hiera('quantum_settings')
$nets = $neutron_settings['predefined_networks']

$nodes_hash = hiera('nodes', {})
$roles = node_roles($nodes_hash, hiera('uid'))

$segment_id = $nets['net04']['L2']['segment_id']
$vm_net_l3 = $nets['net04']['L3']

$tz_type = $::fuel_settings['midonet']['tunnel_type']
$vm_net = { shared => false,
            "L2" => { network_type => $tz_type,
                      router_ext => false,
                      physnet => false,
                      segment_id => $segment_id,
                    },
            "L3" => $vm_net_l3,
            tenant => 'admin'
          }

$alloc = split($nets['net04_ext']['L3']['floating'], ':')
$allocation_pools = "start=${alloc[0]},end=${alloc[1]}"

$metadata_agent_name = $operatingsystem ? {
  'CentOS' => 'neutron-metadata-agent'
}

service { 'neutron-server':
  ensure => running,
}

if member($roles, 'primary-controller') {
  exec {'refresh-dhcp-agent':
    command   => 'crm resource start p_neutron-dhcp-agent',
    path      => '/usr/bin:/usr/sbin',
    tries     => 3,
    try_sleep => 10,
  } ->
  exec {'refresh-metadata-agent':
    command   => 'crm resource start p_neutron-metadata-agent',
    path      => '/usr/bin:/usr/sbin',
    tries     => 3,
    try_sleep => 10,
  } ->

  neutron_network { 'net04':
    ensure                    => present,
    router_external           => $nets['net04']['L2']['router_ext'],
    tenant_name               => $nets['net04']['tenant'],
    shared                    => $nets['net04']['shared']
  } ->

  neutron_subnet { "net04__subnet":
    ensure          => present,
    cidr            => $nets['net04']['L3']['subnet'],
    network_name    => 'net04',
    tenant_name     => $nets['net04']['tenant'],
    gateway_ip      => $nets['net04']['L3']['gateway'],
    enable_dhcp     => $nets['net04']['L3']['enable_dhcp'],
    dns_nameservers => $nets['net04']['L3']['nameservers']
  } ->

  neutron_network { 'net04_ext':
    ensure                    => present,
    router_external           => $nets['net04_ext']['L2']['router_ext'],
    tenant_name               => $nets['net04_ext']['tenant'],
    shared                    => $nets['net04_ext']['shared']
  } ->

  neutron_subnet { "net04_ext__subnet":
    ensure          => present,
    cidr            => $nets['net04_ext']['L3']['subnet'],
    network_name    => 'net04_ext',
    tenant_name     => $nets['net04_ext']['tenant'],
    gateway_ip      => $nets['net04_ext']['L3']['gateway'],
    enable_dhcp     => $nets['net04_ext']['L3']['enable_dhcp'],
    dns_nameservers => $nets['net04_ext']['L3']['nameservers']
  } ->

  neutron_router { 'router04':
    ensure               => present,
    tenant_name          => 'admin',
    gateway_network_name => 'net04_ext',
  } ->

  neutron_router_interface { "router04:net04__subnet":
    ensure => present,
  }

}
