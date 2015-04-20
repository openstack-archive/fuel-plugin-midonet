#    Copyright 2015 Mirantis, Inc.
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
$nodes_hash = $::fuel_settings['nodes']
$node = filter_nodes($nodes_hash,'name',$::hostname)
$internal_address = $node[0]['internal_address']
$gateways = filter_nodes($nodes_hash,'role','midonet-gw')
$gateways_internal_addresses = nodes_to_hash($gateways,'name','internal_address')

stage { 'repos':
} ->
stage { 'zookeeper':
} ->
stage { 'cassandra':
  before => Stage['main']
}

class {'plugin_midonet::repos':
    stage => repos,
}
class {'plugin_midonet::zookeeper':
    stage => zookeeper,
}
class {'plugin_midonet::cassandra':
    stage => cassandra,
}
