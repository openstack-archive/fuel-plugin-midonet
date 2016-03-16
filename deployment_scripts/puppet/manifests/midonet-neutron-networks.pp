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
notice('MODULAR: midonet-neutron-networks.pp')

# Extract data from hiera
$access_data           = hiera_hash('access')
$keystone_admin_tenant = $access_data['tenant']
$network_metadata      = hiera_hash('network_metadata')
$node_roles            = $network_metadata['nodes'][$::hostname]['node_roles']
$neutron_settings      = hiera('neutron_config')
$predefined_nets       = $neutron_settings['predefined_networks']
$tenant_net            = $predefined_nets['admin_internal_net']
$external_net          = $predefined_nets['admin_floating_net']

# Plugin settings data (overrides $external_net l3 values)
$midonet_settings     = hiera_hash('midonet-fuel-plugin')
$tz_type              = $midonet_settings['tunnel_type']
$floating_range_start = $midonet_settings['floating_ip_range_start']
$floating_range_end   = $midonet_settings['floating_ip_range_end']
$floating_cidr        = $midonet_settings['floating_cidr']
$floating_gateway_ip  = $midonet_settings['gateway']

$allocation_pools = "start=$floating_range_start,end=$floating_range_end"

service { 'neutron-server':
  ensure => running,
}

neutron_network { 'net04':
  ensure                    => present,
  router_external           => $tenant_net['L2']['router_ext'],
  tenant_name               => $tenant_net['tenant'],
  shared                    => $tenant_net['shared']
} ->

neutron_subnet { "net04__subnet":
  ensure          => present,
  cidr            => $tenant_net['L3']['subnet'],
  network_name    => 'net04',
  tenant_name     => $tenant_net['tenant'],
  gateway_ip      => $tenant_net['L3']['gateway'],
  enable_dhcp     => $tenant_net['L3']['enable_dhcp'],
  dns_nameservers => $tenant_net['L3']['nameservers']
} ->

neutron_network { 'net04_ext':
  ensure                    => present,
  router_external           => $external_net['L2']['router_ext'],
  tenant_name               => $external_net['tenant'],
  shared                    => $external_net['shared']
} ->

neutron_subnet { "net04_ext__subnet":
  ensure           => present,
  cidr             => $floating_cidr,
  network_name     => 'net04_ext',
  tenant_name      => $external_net['tenant'],
  gateway_ip       => $floating_gateway_ip,
  enable_dhcp      => $external_net['L3']['enable_dhcp'],
  dns_nameservers  => $external_net['L3']['nameservers'],
  allocation_pools => $allocation_pools
} ->

neutron_router { 'router04':
  ensure               => present,
  tenant_name          => $external_net['tenant'],
  gateway_network_name => 'net04_ext',
} ->

neutron_router_interface { "router04:net04__subnet":
  ensure => present,
}
