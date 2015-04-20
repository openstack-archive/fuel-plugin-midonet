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

class plugin_midonet::controller {
  $midokura_user = $fuel_settings['midonet']['midokura_user']
  $midokura_password = $fuel_settings['midonet']['midokura_password']

  include plugin_midonet::neutron
  Package['openstack-neutron-midonet'] -> Neutron_plugin_midonet <||> ~> Service<| title == 'neutron' |>
  Neutron_plugin_midonet <||> ->  Exec<| title == 'neutron-db-sync_plugin' |>
  Neutron_plugin_midonet <||> ->  Exec<| title == 'neutron-db-sync' |>
  Neutron_dhcp_agent_config<||> ~> Service<| title == 'neutron' |>

  #  file { '/etc/yum.repos.d/midokura.repo':
  #   content => template('plugin_midonet/midokura.repo.erb'),
  #  }

  file { '/var/run/netns':
    mode => '0755',
  }

  package { 'python-neutron-plugin-midonet':
    ensure => present,
  } ->
  package { 'python-midonetclient':
    ensure => present,
  } ->
  package { 'openstack-neutron-midonet':
    ensure => present,
  }

  neutron_plugin_midonet {
    'midonet/midonet_uri':        value => "http://${::midonet_api_address}:8081/midonet-api";
    'midonet/username':           value => $::access_hash['user'];
    'midonet/password':           value => $::access_hash['password'];
    'midonet/project_id':         value => $::access_hash['tenant'];
    'midonet/auth_url':           value => "http://${::service_endpoint}:35357/v2.0";
  }

  file {'/etc/neutron/plugin.ini':
    ensure  => link,
    target  => '/etc/neutron/plugins/midonet/midonet.ini',
    require => Package['python-neutron-plugin-midonet']
  }
  file { '/usr/lib/python2.6/site-packages/midonet':
    ensure => link,
    target  => '/usr/lib/python2.7/site-packages/midonet',
    require => Package['python-neutron-plugin-midonet']
  }

  file { '/root/.midonetrc':
    content => template('plugin_midonet/midonetrc.erb'),
  }

#  exec { 'drop_neutron_database':
#    refreshonly => true,
#    notify => Service['neutron'],
#  }

#  neutron_dhcp_agent_config {
#    'DEFAULT/enable_isolated_metadata': value => 'True';
#    'DEFAULT/dhcp_driver':              value => 'neutron.plugins.midonet.agent.midonet_driver.DhcpNoOpDriver';
#    'DEFAULT/interface_driver':         value => 'neutron.agent.linux.interface.MidonetInterfaceDriver';
#    'DEFAULT/ovs_use_veth':             value => 'False';
#    'DEFAULT/root_helper':              value => 'sudo /usr/local/bin/neutron-rootwrap /etc/neutron/rootwrap.conf';
#    'DEFAULT/use_namespaces':           value => 'True';
#    'DEFAULT/debug':                    value => 'True';
#  }

}
