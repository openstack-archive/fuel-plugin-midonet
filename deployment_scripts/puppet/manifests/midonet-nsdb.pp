#    Copyright 2015 Midokura SARL.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

$fuel_settings = parseyaml($astute_settings_yaml)
$all_nodes = $fuel_settings['nodes']
$nsdb_nodes = filter_nodes($all_nodes, 'role', 'nsdb')
$zoo_hash = generate_zookeeper_hash($nsdb_nodes)
$cass_hash = nodes_to_hash($nsdb_nodes, 'name', 'internal_address')

$m_version = 'v2015.06'

$midonet_settings = $fuel_settings['midonet-fuel-plugin']
$mem = $midonet_settings['mem']
$mem_version = $midonet_settings['mem_version']
$mem_user = $midonet_settings['mem_repo_user']
$mem_password = $midonet_settings['mem_repo_password']

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

class {'::midonet::zookeeper':
  servers   => values($zoo_hash),
  server_id => $zoo_hash["${::fqdn}"]['id'],
  client_ip => $zoo_hash["${::fqdn}"]['host'],
  require   => Class['::midonet::repository']
}

class {'::midonet::cassandra':
  seeds        => values($cass_hash),
  seed_address => $cass_hash["${::hostname}"],
  require   => Class['::midonet::repository']
}

firewall {'500 zookeeper ports':
  port    => '2888-3888',
  proto   => 'tcp',
  action  => 'accept',
  require => Class['::midonet::zookeeper']
}

firewall {'501 zookeeper ports':
  port => '2181',
  proto => 'tcp',
  action => 'accept',
  require => Class['::midonet::zookeeper']
}

firewall {'550 cassandra ports':
  port => '9042',
  proto => 'tcp',
  action => 'accept',
  require => Class['::midonet::cassandra']
}

firewall {'551 cassandra ports':
  port => '7000',
  proto => 'tcp',
  action => 'accept',
  require => Class['::midonet::cassandra']
}

firewall {'552 cassandra ports':
  port => '7199',
  proto => 'tcp',
  action => 'accept',
  require => Class['::midonet::cassandra']
}

firewall {'553 cassandra ports':
  port => '9160',
  proto => 'tcp',
  action => 'accept',
  require => Class['::midonet::cassandra']
}

firewall {'554 cassandra ports':
  port => '59471',
  proto => 'tcp',
  action => 'accept',
  require => Class['::midonet::cassandra']
}
