$management_address = hiera('management_vip')
$access_data      = hiera_hash('access')
$username         = $access_data['user']
$password         = $access_data['password']
$tenant_name      = $access_data['tenant']

$midonet_settings = hiera_hash('midonet-fuel-plugin')
$f_net_cidr = split($midonet_settings['floating_cidr'], '/')
$remote_peers = generate_remote_peers($midonet_settings)

$nodes_hash = hiera('nodes')
$node = filter_nodes($nodes_hash, 'fqdn', $::fqdn)
$gw_ip = $node[0]['public_address']
$gw_mask = $node[0]['public_netmask']
$net_hash = public_network_hash($gw_ip, $gw_mask)

notify {"peers":
   message => "floating neeet si $remote_peers"
}

exec {"set down external bridge":
 path    => "/usr/bin:/usr/sbin:/sbin",
  command => "ip link set dev br-ex down"
} ->

exec {"remove bridge ip address":
  path    => "/usr/bin:/usr/sbin:/sbin",
  command => "ip a del $::ipaddress_br_ex dev br-ex",
  onlyif  => "ip -4 a | /bin/grep br-ex"
} ->

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
  source => "/etc/fuel/plugins/midonet-fuel-plugin-3.0/puppet/files/startup.conf"
} ->

midonet_gateway { $::fqdn:
  ensure          => present,
  midonet_api_url => "http://${management_address}:8081/midonet-api",
  username        => $username,
  password        => $password,
  tenant_name     => $tenant_name,
  interface       => 'gw-veth-mn',
  local_as        => $midonet_settings['local_as'],
  bgp_port        => { 'port_address' => $gw_ip, 'net_prefix' => $net_hash['network_address'], 'net_length' => $net_hash['mask']},
  remote_peers    => $remote_peers,
  advertise_net   => [{ 'net_prefix' => $f_net_cidr[0], 'net_length' => $f_net_cidr[1]}]
}
