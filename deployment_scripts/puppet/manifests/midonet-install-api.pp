$fuel_settings = parseyaml($astute_settings_yaml)
$all_nodes = $fuel_settings['nodes']
$nsdb_nodes = filter_nodes($all_nodes, 'role', 'nsdb')
$zoo_ips = generate_api_zookeeper_ips($nsdb_nodes)
$m_version = 'v2015.06'
$primary_controller_nodes = filter_nodes($all_nodes, 'role', 'primary-controller')
$controllers = concat($primary_controller_nodes, filter_nodes($all_nodes, 'role', 'controller'))

$midonet_settings = $fuel_settings['midonet-fuel-plugin']
$mem = $midonet_settings['mem']
$mem_version = $midonet_settings['mem_version']
$mem_user = $midonet_settings['mem_repo_user']
$mem_password = $midonet_settings['mem_repo_password']

# MidoNet API manifest

$key_content = "-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mI0ETb6aOgEEAMVw8Vnwk+zpDtsc0gSW10JEe48zKr2vpl9tQgWAFOPgOA1NglYM
w/xT6Rns7CrYxPR0cb3DeMFtFdMkfWXO0R6x4yHrozMDY/DpvwgYQclIIbcYYe0p
83nlBp793D2dSq60HWuXJu3oi0wQQuR0/jTmOnjxzCzu5jKdJeXihl95ABEBAAG0
Jk1pZG9rdXJhIChNaWRva3VyYSkgPGluZm9AbWlkb2t1cmEuanA+iLgEEwECACIF
Ak2+mjoCGwMGCwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEGezjToFQxTNAp0D
/2c+PLnRFzEXCztXT+05xoO1mPzpm3x2p5ecVPGHR8IxhozlN9DDGDdnvNfMOhi6
nv/G2l86+9Fj8Dz01ne0RZzZHSS1DF/zb6dMYrPJqiT1DXKH0Y73OL/+M7rsutEq
0B/DKhjdBfFPutk3gerEUZPNfIhScE3tnwCnVGJKPQbFuI0ETb6aOgEEANLJK3gm
Xrsp1VKnt663RoxZgoFQgQ6wHaZZWhULTteafjoThX9tj7FidR2+7qJLwpa57M9d
rib4OlbW+rE4PW199/Uqfy86gLv76Q2GZMpzaYB1ZZow0Ny1RTCwh7apkhR/8fCU
pq37aODQ4YwBpZC54iXVKfcntpdJFoObIqXtABEBAAGInwQYAQIACQUCTb6aOgIb
DAAKCRBns406BUMUzfzOBACKx4jChKTAl6HfldOxVN7o8DQpd5rgkHIEj062ym4Z
q5t2v3oaz0H0P2WV66MAhOujgX0V1duZi8fKHdIsdk0nvEa/mV0QS6pEAeZh+dbL
kKyu1J4MSi5l+L+te5XjYBGpoRa3ZGrIR3CkA0oQDCOh312SrcH6Tn9RBPChVSig
zg==
=zF5K
-----END PGP PUBLIC KEY BLOCK-----"

if $mem {
  case $operatingsystem {
    'CentOS': {
      class { '::midonet::repository':
        midonet_repo           => "http://${mem_user}:${mem_password}@yum.midokura.com/repo/${mem_version}/stable/RHEL",
        manage_distro_repo     => false,
        midonet_key_url        => "http://${mem_user}:${mem_password}@yum.midokura.com/repo/RPM-GPG-KEY-midokura",
        midonet_openstack_repo => "http://${mem_user}:${mem_password}@yum.midokura.com/repo/openstack-juno/stable/RHEL",
        midonet_stage          => '',
        openstack_release      => 'juno'
      }
    }
    'Ubuntu': {
      apt::key { 'BC4E4E90DDA81C21396081CC67B38D3A054314CD':
        key_content => $key_content
      } ->

      class { '::midonet::repository':
        midonet_repo           => "http://${mem_user}:${mem_password}@apt.midokura.com/midonet/${mem_version}/stable",
        manage_distro_repo     => false,
        midonet_openstack_repo => "http://${mem_user}:${mem_password}@apt.midokura.com/openstack/juno/stable",
        midonet_stage          => 'trusty',
        openstack_release      => 'juno'
      }
    }
  }
} else {
  case $operatingsystem {
    'CentOS': {
      class { '::midonet::repository':
        midonet_repo       => "http://repo.midonet.org/midonet/${m_version}/RHEL",
        manage_distro_repo => false,
        openstack_release  => 'juno'
      }
    }
    'Ubuntu': {
      class { '::midonet::repository':
        midonet_repo       => "http://repo.midonet.org/midonet/${m_version}",
        manage_distro_repo => false,
        openstack_release  => 'juno'
      }
    }
  }
}

class {'::midonet::midonet_api':
  zk_servers           => $zoo_ips,
  keystone_auth        => true,
  keystone_host        => $::fuel_settings['management_vip'],
  keystone_admin_token => $::fuel_settings['keystone']['admin_token'],
  keystone_tenant_name => $::fuel_settings['access']['tenant'],
  bind_address         => $::ipaddress_br_mgmt,
  api_ip               => $::fuel_settings['public_vip'],
  api_port             => '8081',
  require              => Class['::midonet::repository']
}

# HA proxy configuration
Haproxy::Service        { use_include   => true }
Haproxy::Balancermember { use_include => true }

Openstack::Ha::Haproxy_service {
  server_names        => filter_hash($controllers, 'name'),
  ipaddresses         => filter_hash($controllers, 'internal_address'),
  public_virtual_ip   => $::fuel_settings['public_vip'],
  internal_virtual_ip => $::fuel_settings['management_vip'],
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


firewall {'502 Midonet api':
  port => '8081',
  proto => 'tcp',
  action => 'accept',
}
