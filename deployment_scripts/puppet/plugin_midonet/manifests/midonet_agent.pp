class plugin_midonet::midonet_agent {
  #  include nova::params
  plugin_midonet::kern_module { 'vhost_net':
    ensure => present,
  }

  #  package { 'midolman':
  #  ensure => present,
  #}
#  nova_config {
#    'DEFAULT/libvirt_vif_driver': value => 'nova.virt.libvirt.vif.LibvirtGenericVIFDriver';
#    'MIDONET/midonet_use_tunctl': value => "True";
#    'MIDONET/midonet_uri':        value => "http://${::midonet_api_address}:8081/midonet-api"
#    'MIDONET/username':           value => $::access_hash['user'];
#    'MIDONET/password':           value => $::access_hash['password'];
#    'MIDONET/project_id':         value => $::access_hash['tenant'];
#    'MIDONET/auth_url':           value => "http://${::service_endpoint}:35357/v2.0";
#  }
#
#  service { 'nova-compute':
#    name => $::nova::params::compute_service_name,
#    ensure => running,
#  }

# Nova_config <||> ~> Service['nova-compute']

#  $zoo_nodes = inline_template("<%= scope.lookupvar('::gateways_internal_addresses').collect { |name,info| info+':2181'}.join(',') %>")
#  $cassanda_nodes = inline_template("<%= scope.lookupvar('::gateways_internal_addresses').values.join(',')%>")
#
#  midolman_config {
#    'zookeeper/zookeeper_hosts': value => $zoo_nodes;
#    'cassandra/servers': value => $cassanda_nodes;
#    'cassandra/replication_factor': values => 3;
#  } ~>
#  service { 'midolman':
#    ensure => running,
#  }

}
