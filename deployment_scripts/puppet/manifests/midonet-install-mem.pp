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
notice('MODULAR: midonet-install-mem.pp')
include ::stdlib

# Extract data from hiera
$ssl_hash                   = hiera_hash('use_ssl', {})

$midonet_settings           = hiera('midonet')
$net_metadata               = hiera_hash('network_metadata')
$controllers_map            = get_nodes_hash_by_roles($net_metadata, ['controller', 'primary-controller'])
$controllers_mgmt_ips       = get_node_to_ipaddr_map_by_network_role($controllers_map, 'management')
$nsdb_hash                  = get_nodes_hash_by_roles($net_metadata, ['nsdb'])
$nsdb_mgmt_ips              = get_node_to_ipaddr_map_by_network_role($nsdb_hash, 'management')
$zoo_ips_hash               = generate_api_zookeeper_ips(values($nsdb_mgmt_ips))
$management_vip             = hiera('management_vip')
$public_vip                 = hiera('public_vip')
$keystone_data              = hiera_hash('keystone')
$access_data                = hiera_hash('access')
$public_ssl_hash            = hiera('public_ssl')
$cass_ips                   = values($nsdb_mgmt_ips)
$mem                        = $midonet_settings['mem']
$admin_identity_protocol    = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'protocol', 'http')
$metadata_hash              = hiera_hash('quantum_settings', {})
$metadata_secret            = pick($metadata_hash['metadata']['metadata_proxy_shared_secret'], 'root')

$ana_hash               = get_nodes_hash_by_roles($net_metadata, ['midonet-analytics'])
$ana_mgmt_ip_hash       = get_node_to_ipaddr_map_by_network_role($ana_hash, 'management')
$ana_mgmt_ip_list       = values($ana_mgmt_ip_hash)
$ana_keys               = keys($ana_hash)

$ana_mgmt_ip            = empty($ana_keys)? {true => $public_vip , default => $ana_mgmt_ip_list[0] }


$public_ssl             = hiera_hash('public_ssl')
$ssl_horizon            = $public_ssl['horizon']

service { 'apache2':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
}

#Add MEM manager class
class {'midonet::mem':
  cluster_ip   => $public_vip,
  analytics_ip => $public_vip,
  is_insights  => $midonet_settings['mem_use_insights'],
}

  exec { "a2enmod headers":
      path    => "/usr/bin:/usr/sbin:/bin",
      alias   => 'enable-mod-headers',
      creates => '/etc/apache2/mods-enabled/headers.load',
      notify  => Service['apache2'],
      tag     => 'a2enmod-mem'
  }

  exec { "a2enmod proxy":
      path    => "/usr/bin:/usr/sbin:/bin",
      alias   => 'enable-mod-proxy',
      creates => '/etc/apache2/mods-enabled/proxy.load',
      notify  => Service['apache2'],
      tag     => 'a2enmod-mem'
  }

  exec { "a2enmod proxy_http":
      path    => "/usr/bin:/usr/sbin:/bin",
      alias   => 'enable-mod-proxy-http',
      creates => '/etc/apache2/mods-enabled/proxy_http.load',
      notify  => Service['apache2'],
      tag     => 'a2enmod-mem'
  }

  exec { "a2enmod proxy_wstunnel":
      path    => "/usr/bin:/usr/sbin:/bin",
      alias   => 'enable-mod-proxy-wstunnel',
      creates => '/etc/apache2/mods-enabled/proxy_wstunnel.load',
      notify  => Service['apache2'],
      tag     => 'a2enmod-mem'
  }

  exec { "a2enmod ssl":
      path    => "/usr/bin:/usr/sbin:/bin",
      alias   => 'enable-mod-ssl',
      creates => '/etc/apache2/mods-enabled/ssl.load',
      notify  => Service['apache2'],
      tag     => 'a2enmod-mem'
  }

file { 'mem-vhost':
  ensure  => present,
  path    => '/etc/apache2/sites-available/30-midonet-mem.conf',
  content => template('/etc/fuel/plugins/midonet-4.0/puppet/templates/vhost_mem_manager.erb'),
}

exec { "a2ensite 30-midonet-mem":
    path    => "/usr/bin:/usr/sbin:/bin",
    alias   => 'enable-mem-vhost',
    creates => '/etc/apache2/sites-enabled/30-midonet-mem.conf',
    notify  => Service['apache2'],
}

Exec<| tag == 'a2enmod-mem' |>
-> File['mem-vhost']
-> Exec['a2ensite 30-midonet-mem']
