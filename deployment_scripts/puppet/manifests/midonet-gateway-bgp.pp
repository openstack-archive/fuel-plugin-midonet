notice('MODULAR: midonet-bgp-interfaces.pp')


exec {"add veth interface":
  path    => "/usr/bin:/usr/sbin:/sbin",
  command => "ip link add gw-veth-br type veth peer name gw-veth-mn",
  unless  => "ip l | /bin/grep gw-veth-br"
} ->

exec {"set gw-veth-br interface up":
  path    => "/usr/bin:/usr/sbin:/sbin",
  command => "ip l set dev gw-veth-br up"
} ->

exec {"set gw-veth-mn interface up":
  path    => "/usr/bin:/usr/sbin:/sbin",
  command => "ip l set dev gw-veth-mn up"
} ->

exec {"add veth to bridge":
  path    => "/usr/bin:/usr/sbin:/sbin",
  command => "brctl addif br-ex gw-veth-br",
  unless  => "brctl show br-ex | /bin/grep gw-veth-br"
} ->

file {"/etc/sysconfig/network-scripts/ifcfg-p_br-floating-0":
  ensure  => absent,
} ->

exec {"set up external bridge":
  path    => "/usr/bin:/usr/sbin:/sbin",
  command => "ip link set dev br-ex up"
} ->

file {"/etc/init/midonet-network.conf":
  ensure => present,
  source => "/etc/fuel/plugins/midonet-4.0/puppet/files/startup.conf"
}

# midonet_gateway { $::fqdn:
#   ensure          => present,
#   midonet_api_url => "http://${management_address}:8181/midonet-api",
#   username        => $username,
#   password        => $password,
#   tenant_name     => $tenant_name,
#   interface       => 'gw-veth-mn',
#   local_as        => $midonet_settings['local_as'],
#   bgp_port        => { 'port_address' => $midonet_settings['bgp_ip'], 'net_prefix' => $bgp_subnet_ip, 'net_length' => $bgp_subnet_cidr },
#   remote_peers    => $remote_peers,
#   advertise_net   => [{ 'net_prefix' => $f_net_cidr[0], 'net_length' => $f_net_cidr[1]}]
# }
