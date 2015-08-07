$fuel_settings = parseyaml($astute_settings_yaml)
$management_address = hiera('management_vip')
$username = $fuel_settings['access']['user']
$password = $fuel_settings['access']['password']
$midonet_settings = $fuel_settings['midonet-fuel-plugin']
$gateway_nodes = filter_nodes($fuel_settings['nodes'], 'role', 'midonet-gw')
$gateways_hash_ips = nodes_to_hash($gateway_nodes, 'name', 'public_address')
$gw_ip = $gateways_hash_ips[$::hostname]
$gateways_hash_mask = nodes_to_hash($gateway_nodes, 'name', 'public_netmask')
$gw_mask = $gateways_hash_mask[$::hostname]
$net_hash = public_network_hash($gw_ip, $gw_mask)
$f_net_cidr = split($midonet_settings['floating_cidr'], '/')
$remote_peers = generate_remote_peers($midonet_settings)

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
  source => "/etc/fuel/plugins/midonet-fuel-plugin-2.0/puppet/files/startup.conf"
} ->

midonet_gateway { $::fqdn:
  ensure          => present,
  midonet_api_url => "http://${management_address}:8081/midonet-api",
  username        => $username,
  password        => $password,
  interface       => 'gw-veth-mn',
  local_as        => $midonet_settings['local_as'],
  bgp_port        => { 'port_address' => $gw_ip, 'net_prefix' => $net_hash['network_address'], 'net_length' => $net_hash['mask']},
  remote_peers    => $remote_peers,
  advertise_net   => [{ 'net_prefix' => $f_net_cidr[0], 'net_length' => $f_net_cidr[1]}]
}
