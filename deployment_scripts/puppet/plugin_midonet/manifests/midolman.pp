class plugin_midonet::midolman {
  if $::fuel_settings['role'] == 'compute' {
    plugin_midonet::kern_module { 'vhost_net':
      ensure => present,
    }
  }
  $zoo_nodes = inline_template("<%= scope.lookupvar('::gateways_internal_addresses').collect { |name,info| info+':2181'}.join(',') %>")
  $cassanda_nodes = inline_template("<%= scope.lookupvar('::gateways_internal_addresses').values.join(',')%>")
  package { 'midolman':
    ensure => present,
  } ->
  midolman_config {
    'zookeeper/zookeeper_hosts': value => $zoo_nodes;
    'cassandra/servers': value => $cassanda_nodes;
    'cassandra/replication_factor': value => 3;
    'midolman/bgpd_binary': value => '/usr/sbin';
  } ~>
  service { 'midolman':
    ensure => running,
  }
  
  if $::fuel_settings['role'] == 'midonet-gw' or $::fuel_settings['role'] == 'midonet-simplegw' {
    l23network::l3::ifconfig {$::fuel_settings['midonet']['bgb1_iface']:
      ipaddr => 'none',
      check_by_ping => 'none',
    }
    l23network::l3::ifconfig {$::fuel_settings['midonet']['bgb2_iface']:
      ipaddr => 'none',
      check_by_ping => 'none',
    }
  }
}
