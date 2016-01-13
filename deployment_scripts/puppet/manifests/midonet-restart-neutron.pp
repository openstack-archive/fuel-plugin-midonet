# Extract data from hiera
$access_data           = hiera_hash('access')
$keystone_admin_tenant = $access_data['tenant']
$network_metadata      = hiera_hash('network_metadata')
$node_roles            = $network_metadata['nodes'][$::hostname]['node_roles']
$neutron_settings      = hiera('quantum_settings')
$nets                  = $neutron_settings['predefined_networks']
$segment_id            = $nets['net04']['L2']['segment_id']
$vm_net_l3             = $nets['net04']['L3']

# Plugin settings data
$midonet_settings = hiera_hash('midonet-fuel-plugin')
$tz_type          = $midonet_settings['tunnel_type']
$range_start      = $midonet_settings['floating_ip_range_start']
$range_end        = $midonet_settings['floating_ip_range_end']

$vm_net = { shared => false,
            "L2" => { network_type => $tz_type,
                      router_ext => false,
                      physnet => false,
                      segment_id => $segment_id,
                    },
            "L3" => $vm_net_l3,
            tenant => 'admin'
          }

$allocation_pools = "start=$range_start,end=$range_end"

service { 'neutron-server':
  ensure => running,
}

if member($node_roles, 'primary-controller') {
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
    ensure           => present,
    cidr             => $midonet_settings['floating_cidr'],
    network_name     => 'net04_ext',
    tenant_name      => $nets['net04_ext']['tenant'],
    gateway_ip       => $midonet_settings['gateway'],
    enable_dhcp      => $nets['net04_ext']['L3']['enable_dhcp'],
    dns_nameservers  => $nets['net04_ext']['L3']['nameservers'],
    allocation_pools => $allocation_pools
  } ->

  neutron_router { 'router04':
    ensure               => present,
    tenant_name          => $nets['net04_ext']['tenant'],
    gateway_network_name => 'net04_ext',
  } ->

  neutron_router_interface { "router04:net04__subnet":
    ensure => present,
  }

}
