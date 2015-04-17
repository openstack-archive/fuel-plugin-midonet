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

$fuel_settings = parseyaml($astute_settings_yaml)
$nodes_hash = $::fuel_settings['nodes']
$node = filter_nodes($nodes_hash,'name',$::hostname)

#Network
$internal_address = $node[0]['internal_address']
$public_int   = $::fuel_settings['public_interface']
$gateways = filter_nodes($nodes_hash,'role','midonet-gw')
$gateways_internal_addresses = nodes_to_hash($gateways,'name','internal_address')

#amqp
$primary_controller_nodes = filter_nodes($nodes_hash,'role','primary-controller')
$controllers = concat($primary_controller_nodes, filter_nodes($nodes_hash,'role','controller'))
$controller_internal_addresses = nodes_to_hash($controllers,'name','internal_address')
$controller_nodes = ipsort(values($controller_internal_addresses))
if $::internal_address in $controller_nodes {
  # prefer local MQ broker if it exists on this node
  $amqp_nodes = concat(['127.0.0.1'], fqdn_rotate(delete($controller_nodes, $::internal_address)))
} else {
  $amqp_nodes = fqdn_rotate($controller_nodes)
}
$amqp_port = '5673'
$amqp_hosts = inline_template("<%= @amqp_nodes.map {|x| x + ':' + @amqp_port}.join ',' %>")
$amqp_user = 'nova'
$amqp_password = $::fuel_settings['rabbit']['password']



$access_hash          = $::fuel_settings['access']
$midonet_api_address = $primary_controller_nodes[0]['internal_address']

#Logging
$verbose = true
$debug = $::fuel_settings['debug']
$use_syslog = $::fuel_settings['use_syslog'] ? { default=>true }
$syslog_log_facility_neutron    = 'LOG_LOCAL4'

#Neutron
$db_host                       = $::fuel_settings['management_vip']
$neutron_db_user               = 'neutron'
$neutron_config                = $::fuel_settings['quantum_settings']
$network_provider              = 'neutron'
$neutron_db_password           = $neutron_config['database']['passwd']
$neutron_user_password         = $neutron_config['keystone']['admin_password']
$neutron_metadata_proxy_secret = $neutron_config['metadata']['metadata_proxy_shared_secret']
$base_mac                      = 'fa:16:3e:00:00:00'
$neutron_db_dbname             = 'neutron'
$service_plugins               = ['neutron.services.l3_router.l3_router_plugin.L3RouterPlugin','neutron.services.metering.metering_plugin.MeteringPlugin']
$mechanism_drivers             = 'openvswitch'
$service_endpoint              = $::fuel_settings['management_vip']

#Nova
$nova_user_password = $::fuel_settings['nova']['user_password']
stage { 'repos':
  before => Stage['main']
}


class {'plugin_midonet::repos':
  stage => repos,
}
class {'plugin_midonet::controller': 
} ->
exec { '/etc/init.d/tomcat6 restart':
}
