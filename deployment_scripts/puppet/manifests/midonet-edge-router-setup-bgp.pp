#    Copyright 2016 Midokura, SARL.
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
notice('MODULAR: midonet-edge-router-setup-static.pp')

include ::stdlib
# Extract data from hiera
$access_data           = hiera_hash('access')
$keystone_admin_tenant = $access_data['tenant']
$net_metadata          = hiera_hash('network_metadata')
$gw_hash               = get_nodes_hash_by_roles($net_metadata, ['midonet-gw'])
$gw_mgmnt_ips          = get_node_to_ipaddr_map_by_network_role($gw_hash, 'management')
$neutron_settings      = hiera('neutron_config')
$external_net_name     = $neutron_settings['default_floating_net']
$tenant_net_name       = $neutron_settings['default_private_net']
$predefined_nets       = $neutron_settings['predefined_networks']
$tenant_net            = $predefined_nets[$tenant_net_name]
$external_net          = $predefined_nets[$external_net_name]

# Plugin settings data (overrides $external_net l3 values)
$midonet_settings                = hiera_hash('midonet')
$tz_type                         = $midonet_settings['tunnel_type']
$floating_range_start            = $midonet_settings['floating_ip_range_start']
$floating_range_end              = $midonet_settings['floating_ip_range_end']
$floating_cidr                   = $midonet_settings['floating_cidr']
$floating_gateway_ip             = $midonet_settings['gateway']
$bgp_local_as                    = $midonet_settings['bgp_local_as']
$bgp_neighbors                   = $midonet_settings['bgp_neighbors']

$edge_router = 'edge-router'

$allocation_pools = "start=$floating_range_start,end=$floating_range_end"

# Create one subnet per each network used.

$defaults_for_subnet = {
  ensure       => present,
  enable_dhcp  => false,
  network_name => 'edge-net',
  tenant_id    => $external_net['tenant']
}

create_resources('neutron_subnet',
                generate_bgp_edge_subnet_hash($bgp_neighbors),
                $defaults_for_subnet)

$defaults_for_port = {
  ensure       => present,
  network_name => 'edge-net',
  binding_host_id => $gw_hash[0]['fqdn'],
  binding_profile => {
    'interface_name' => 'gw-veth-mn'
  },
}

create_resources('neutron_port',
                generate_bgp_edge_port_hash($bgp_neighbors),
                $defaults_for_port)

$ports_to_bind = generate_port_bindings_to_create($bgp_neighbors)

file { 'create router interfaces script':
  ensure  => present,
  path    => '/tmp/create_router_interfaces.sh',
  content => template('/etc/fuel/plugins/midonet-4.0/puppet/templates/create_router_interfaces.sh.erb'),
}

# Finally, execute the script
exec { 'run create router interfaces script':
  command => '/bin/bash -x /tmp/create_router_interfaces.sh 2>&1 | tee /tmp/ri-create.out',
  returns => ['0', '7'],
}

Neutron_subnet<||>
-> Neutron_port<||>
-> File['create router interfaces script']
-> Exec['run create router interfaces script']
