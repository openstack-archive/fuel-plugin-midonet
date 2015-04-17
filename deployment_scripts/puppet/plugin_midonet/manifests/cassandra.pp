#    Copyright 2013 Mirantis, Inc.
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

class plugin_midonet::cassandra {
  package { 'dsc20':
    ensure => present,
  }

  file { '/etc/cassandra/conf/cassandra.yaml':
    ensure => present,
    content => template('plugin_midonet/cassandra.yaml.erb'),
    require => Package['dsc20'],
    notify => Service['cassandra'],
  }

  service { 'cassandra':
    ensure => running,
  }

  firewall {'550 cassandra ports':
    port => '9042',
    proto => 'tcp',
    action => 'accept',
  }
  firewall {'551 cassandra ports':
    port => '7000',
    proto => 'tcp',
    action => 'accept',
  }
  firewall {'552 cassandra ports':
    port => '7199',
    proto => 'tcp',
    action => 'accept',
  }
  firewall {'553 cassandra ports':
    port => '9160',
    proto => 'tcp',
    action => 'accept',
  }
  firewall {'554 cassandra ports':
    port => '59471',
    proto => 'tcp',
    action => 'accept',
  }
}
