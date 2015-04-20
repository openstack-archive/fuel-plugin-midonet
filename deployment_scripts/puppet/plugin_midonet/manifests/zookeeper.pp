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

class plugin_midonet::zookeeper {

  package {'java-1.7.0-openjdk-devel.x86_64':
    ensure => present,
  } ->
  package { 'zookeeper':
    ensure => present,
  }->
  file { '/usr/java':
    ensure => directory,
  } ->
  file { '/usr/java/default':
    ensure => directory,
  } ->
  file { '/usr/java/default/bin':
    ensure => directory,
  } ->
  file { '/usr/java/default/bin/java':
    ensure => link,
    target => '/usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java',
  }

  $zoo_nodes = generate_zookeeper_hash($::fuel_settings['nodes'],'midonet-gw')

  file { '/etc/zookeeper/zoo.cfg':
    ensure => present,
    content => template('plugin_midonet/zoo.cfg.erb'),
    require => Package['zookeeper'],
    notify => Service['zookeeper'],
  }

  $myid = $zoo_nodes["${::fqdn}"]['id']
  file { '/var/lib/zookeeper/data':
    ensure => directory,
    require => Package['zookeeper'],
    mode => 0775,
    group => 'hadoop'
  } ->
  file { '/var/lib/zookeeper/data/myid':
    ensure => present,
    content => "${myid}",
  } ~>
  service { 'zookeeper':
    ensure => running,
  }

  firewall {'500 zookeeper ports':
    port => '2888-3888',
    proto => 'tcp',
    action => 'accept',
  }
  firewall {'501 zookeeper ports':
    port => '2181',
    proto => 'tcp',
    action => 'accept',
  }
}
