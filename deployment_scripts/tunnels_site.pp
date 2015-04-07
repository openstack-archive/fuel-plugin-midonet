$fuel_settings = parseyaml($astute_settings_yaml)
$nodes_hash = $::fuel_settings['nodes']
$primary_controller_nodes = filter_nodes($nodes_hash,'role','primary-controller')
$controllers = concat($primary_controller_nodes, filter_nodes($nodes_hash,'role','controller'))
$db_gateways = filter_nodes($nodes_hash,'role','midonet-gw')
$gateways = filter_nodes($nodes_hash,'role','midonet-simplegw')
$computes = filter_nodes($nodes_hash,'role','compute')

$midonet_nodes1 = concat($controllers,$db_gateways)
$midonet_nodes2 = concat($gateways,$computes)
$midonet_nodes = concat($midonet_nodes1,$midonet_nodes2)

$nodes_adresses = nodes_to_hash($midonet_nodes,'fqdn','internal_address')
$access_hash          = $::fuel_settings['access']
$service_endpoint              = $::fuel_settings['management_vip']
$neutron_config                = $::fuel_settings['quantum_settings']

Nova_config<||> -> Exec['/etc/init.d/openstack-nova-api restart']

nova_config {
  'DEFAULT/enabled_apis':                         value => 'ec2,osapi_compute,metadata';
  'DEFAULT/service_neutron_metadata_proxy':       value => 'true';
  'DEFAULT/neutron_metadata_proxy_shared_secret': value => $neutron_config['metadata']['metadata_proxy_shared_secret'];
}
exec { '/etc/init.d/openstack-nova-api restart':
}
if $fuel_settings['role'] == 'primary-controller' {
  $nodes_fqdn = keys($nodes_adresses)
  midonet_tunnel_zone { 'default':
    ensure => present,
  } ->
  midonet_host { $nodes_fqdn:
    ensure => present,
    nodes => $nodes_adresses,
    tunnel_zone => 'default',
    require => Midonet_tunnel_zone['default'],
  }
  #  create_tunnel_zone($nodes_adresses)
}

Neutron_dhcp_agent_config<||> ~> Service['neutron-dhcp-agent']
Neutron_dhcp_agent_config<||> ~> Service['neutron-metadata-agent']

service { 'neutron-dhcp-agent':
  ensure => running,
}
service { 'neutron-metadata-agent':
  ensure => running,
}
neutron_dhcp_agent_config {
  'DEFAULT/enable_isolated_metadata': value => 'True';
  'DEFAULT/dhcp_driver':              value => 'midonet.neutron.agent.midonet_driver.DhcpNoOpDriver';
  'DEFAULT/interface_driver':         value => 'neutron.agent.linux.interface.MidonetInterfaceDriver';
  'DEFAULT/ovs_use_veth':             value => 'False';
  'DEFAULT/root_helper':              value => 'sudo /usr/local/bin/neutron-rootwrap /etc/neutron/rootwrap.conf';
  'DEFAULT/use_namespaces':           value => 'True';
  'DEFAULT/debug':                    value => 'False';
  'midonet/midonet_uri':              value => "http://${::service_endpoint}:8081/midonet-api";
  'midonet/username':                 value => $::access_hash['user'];
  'midonet/password':                 value => $::access_hash['password'];
  'midonet/project_id':               value => $::access_hash['tenant'];
  'midonet/auth_url':                 value => "http://${::service_endpoint}:35357/v2.0";
}

