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

#Add MEM manager class
class {'midonet::mem':
  cluster_ip   => $public_vip,
  analytics_ip => $public_vip,
  is_insights  => $midonet_settings['mem_use_insights'],
}

class {'midonet::mem::vhost':
  cluster_ip   => $public_vip,
  analytics_ip => $public_vip,
  is_insights  => $midonet_settings['mem_use_insights'],
  is_ssl       => empty($ssl_hash)? {true => undef , default => true},
}


if $midonet_settings['mem_use_ssl'] {
  # http version of horizon should just redirect to https version
  openstack::ha::haproxy_service { 'horizon':
    order                  => '015',
    listen_port            => 80,
    server_names           => undef,
    ipaddresses            => undef,
    haproxy_config_options => {
      'option'   => 'http-buffer-request',
      'timeout'  => 'http-request 10s',
      'redirect' => 'scheme https if !{ ssl_fc }'
    },
  }

  openstack::ha::haproxy_service { 'horizon-ssl':
    order                  => '017',
    listen_port            => 443,
    balancermember_port    => 80,
    public_ssl             => $use_ssl,
    public_ssl_path        => $public_ssl_path,
    haproxy_config_options => {
      'option'      => ['forwardfor', 'httpchk', 'forceclose', 'httplog', 'http-buffer-request'],
      'timeout'     => ['client 3h', 'server 3h', 'http-request 10s'],
      'stick-table' => 'type ip size 200k expire 30m',
      'stick'       => 'on src',
      'balance'     => 'source',
      'mode'        => 'http',
      'reqadd'      => 'X-Forwarded-Proto:\ https',
    },
    balancermember_options => 'weight 1 check',
  }
} else {
  # http only
  openstack::ha::haproxy_service { 'horizon':
    order                  => '015',
    listen_port            => 80,
    define_cookies         => true,
    haproxy_config_options => {
      'option'  => ['forwardfor', 'httpchk', 'forceclose', 'httplog', 'http-buffer-request'],
      'timeout' => ['client 3h', 'server 3h', 'http-request 10s'],
      'rspidel' => '^Set-cookie:\ IP=',
      'balance' => 'source',
      'mode'    => 'http',
      'cookie'  => 'SERVERID insert indirect nocache',
      'capture' => 'cookie vgnvisitor= len 32',
    },
    balancermember_options => 'check inter 2000 fall 3',
  }
}
