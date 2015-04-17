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

class plugin_midonet::repos {
  include l23network::params

  package { 'openvswitch':
    name => $::l23network::params::ovs_common_package_name,
    ensure => absent,
  } ->
  package { 'openvswitch-datapath':
    name => $::l23network::params::ovs_datapath_package_name,
    ensure => absent,
  }

  file { '/etc/yum.repos.d/CentOS-Base.repo':
    ensure => present,
    content => template('plugin_midonet/CentOS-Base.repo'),
  }

  file { '/etc/yum.repos.d/epel.repo':
    ensure => present,
    content => template('plugin_midonet/epel.repo'),
  }

  yumrepo { 'midokura':
#    ensure   => present,
    gpgcheck => 0,
    enabled  => 1,
    baseurl  => "http://${::fuel_settings['midonet']['repo_username']}:${::fuel_settings['midonet']['repo_password']}@yum.midokura.com/repo/v1.8/stable/RHEL/6/",
#    gpgkey   => "http://<%= midokura_user %>:<%= midokura_password %>@yum.midokura.com/repo/RPM-GPG-KEY-midokura",
  }

  yumrepo { 'midokura_neutron_pligin':
#    ensure   => present,
    gpgcheck => 0,
    enabled  => 1,
    baseurl  => "http://${::fuel_settings['midonet']['repo_username']}:${::fuel_settings['midonet']['repo_password']}@yum.midokura.com/repo/openstack-juno/stable/RHEL/6/",
#    gpgkey   => "http://<%= midokura_user %>:<%= midokura_password %>@yum.midokura.com/repo/RPM-GPG-KEY-midokura",
  }

  yumrepo { 'datastax':
#    ensure => present,
    gpgcheck => 0,
    enabled  => 1,
    baseurl  => "http://rpm.datastax.com/community",
  }
}
