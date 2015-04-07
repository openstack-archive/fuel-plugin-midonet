class plugin_midonet::neutron {

  $primary_controller = $::fuel_settings['role'] ? { 'primary-controller'=>true, default=>false }
  if $primary_controller {
    if ($::neutron::params::server_package) {
      # Debian platforms
      Package<| title == 'neutron-server' |> ~> Exec['neutron-db-sync']
    } else {
      # RH platforms
      Package<| title == 'neutron' |> ~> Exec['neutron-db-sync']
    }
    exec { 'neutron-db-sync_plugin':
      command     => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head',
      path        => '/usr/bin',
      refreshonly => true,
      tries       => 10,
      # TODO(bogdando) contribute change to upstream:
      #   new try_sleep param for sleep driven development (SDD)
      try_sleep   => 20,
    }
    #NOTE(bogdando) contribute change to upstream #1384133
    Neutron_config<||> -> Exec['neutron-db-sync']
    Exec['neutron-db-sync'] -> Service<| title == 'neutron-server' |>
  }

  plugin_midonet::db { $::neutron_db_dbname:
    user => $::neutron_db_user,
    password => $::neutron_db_password,
    allowed_hosts => [ '%', $::hostname ],
    host => '127.0.0.1',
  }

  if $primary_controller {
    class { 'neutron::keystone::auth':
      password         => $::neutron_user_password,
      public_address   => $::fuel_settings['public_vip'],
      admin_address    => $::fuel_settings['management_vip'],
      internal_address => $::fuel_settings['management_vip'],
    }
  }

  class { 'cluster::haproxy_ocf':
    primary_controller => $primary_controller
  }
  Haproxy::Service        { use_include => true }
  Haproxy::Balancermember { use_include => true }

  Openstack::Ha::Haproxy_service {
    server_names        => filter_hash($::controllers, 'name'),
    ipaddresses         => filter_hash($::controllers, 'internal_address'),
    public_virtual_ip   => $::fuel_settings['public_vip'],
    internal_virtual_ip => $::fuel_settings['management_vip'],
  }


  class { 'openstack::ha::neutron': }
  class { 'openstack::network':
    network_provider    => $::neutron_db_user,
    agents              => ['dhcp', 'metadata'],
    ha_agents           => false,
    verbose             => $::verbose,
    debug               => $::debug,
    use_syslog          => $::use_syslog,
    syslog_log_facility => $::syslog_log_facility_neutron,

    neutron_server      => true,
    neutron_db_uri      => "mysql://${::neutron_db_user}:${::neutron_db_password}@${::db_host}/${::neutron_db_dbname}?&read_timeout=60",
    public_address      => $::fuel_settings['public_vip'],
    internal_address    => $::fuel_settings['management_vip'], # Could be this node or, internal_vip
    admin_address       => $::fuel_settings['management_vip'],
    nova_neutron        => true,
    base_mac            => $::base_mac,
    core_plugin         => 'midonet.neutron.plugin.MidonetPluginV2',
    service_plugins     => '',

    #ovs
    mechanism_drivers   => $::mechanism_drivers,
    local_ip            => $::internal_address, # $::internal_adress is this node
#    bridge_mappings     => $bridge_mappings,
#    network_vlan_ranges => $vlan_range,
#    enable_tunneling    => $enable_tunneling,
#    tunnel_id_ranges    => $tunnel_id_ranges,

    #Queue settings
    queue_provider  => 'rabbitmq',
    amqp_hosts      => [$::amqp_hosts],
    amqp_user       => $::amqp_user,
    amqp_password   => $::amqp_password,

    # keystone
    admin_password  => $::neutron_user_password,
    auth_host       => $::internal_address,
    auth_url        => "http://${::service_endpoint}:35357/v2.0",
    neutron_url     => "http://${::service_endpoint}:9696",

    #metadata
    shared_secret   => $::neutron_metadata_proxy_secret,
    metadata_ip     => $::service_endpoint,

    #nova settings
    private_interface   => false,
    public_interface    => $::public_int,
    fixed_range         => false,
    floating_range      => false,
#    network_manager     => $network_manager,
#   network_config      => $config_overrides,
    create_networks     => false,
#    num_networks        => $num_networks,
#    network_size        => $network_size,
#   nameservers         => $nameservers,
    enable_nova_net     => false,  # just setup networks, but don't start nova-network service on controllers
    nova_admin_password => $::nova_user_password,
    nova_url            => "http://${service_endpoint}:8774/v2",
  }
}
