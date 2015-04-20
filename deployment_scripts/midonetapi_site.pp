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
$primary_controller_nodes = filter_nodes($nodes_hash,'role','primary-controller')
$controllers = concat($primary_controller_nodes, filter_nodes($nodes_hash,'role','controller'))
$service_endpoint              = $::fuel_settings['management_vip']
stage { 'repos':
    before => Stage['main']
}


class {'plugin_midonet::repos':
    stage => repos,
}

class {'plugin_midonet::midonetapi':
}
