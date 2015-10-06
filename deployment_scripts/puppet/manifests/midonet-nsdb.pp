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

if $mem {
  $mido_repo = $operatingsystem ? {
    'CentOS' => "http://${mem_user}:${mem_password}@yum.midokura.com/repo/${mem_version}/stable/RHEL",
    'Ubuntu' => "http://${mem_user}:${mem_password}@apt.midokura.com/midonet/${mem_version}/stable"
  }
} else {
  $mido_repo = $operatingsystem ? {
    'CentOS' => "http://repo.midonet.org/midonet/${m_version}/RHEL",
    'Ubuntu' => "http://repo.midonet.org/midonet/${m_version}"
  }
}

class {'::midonet::repository':
  midonet_repo       => $mido_repo,
  manage_distro_repo => false,
  openstack_release  => 'juno'
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
