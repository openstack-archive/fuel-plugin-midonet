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

class plugin_midonet::midolman {
  if $::fuel_settings['role'] == 'compute' {
    plugin_midonet::kern_module { 'vhost_net':
      ensure => present,
    }
  }
  $zoo_nodes = inline_template("<%= scope.lookupvar('::gateways_internal_addresses').collect { |name,info| info+':2181'}.join(',') %>")
  $cassanda_nodes = inline_template("<%= scope.lookupvar('::gateways_internal_addresses').values.join(',')%>")
  package { 'midolman':
    ensure => present,
  } ->
  midolman_config {
    'zookeeper/zookeeper_hosts': value => $zoo_nodes;
    'cassandra/servers': value => $cassanda_nodes;
    'cassandra/replication_factor': value => 3;
    'midolman/bgpd_binary': value => '/usr/sbin';
  } ~>
  service { 'midolman':
    ensure => running,
  }
  
  if $::fuel_settings['role'] == 'midonet-gw' or $::fuel_settings['role'] == 'midonet-simplegw' {
    l23network::l3::ifconfig {$::fuel_settings['midonet']['bgb1_iface']:
      ipaddr => 'none',
      check_by_ping => 'none',
    }
    l23network::l3::ifconfig {$::fuel_settings['midonet']['bgb2_iface']:
      ipaddr => 'none',
      check_by_ping => 'none',
    }
  }
}
