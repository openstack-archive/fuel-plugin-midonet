class plugin_midonet::midonetapi {
  $zoo_nodes = generate_zookeeper_hash($::fuel_settings['nodes'],'midonet-gw')
  $keystone_token = $::fuel_settings['keystone']['admin_token']
  $http_port='8081'

  $primary_controller = $::fuel_settings['role'] ? { 'primary-controller'=>true, default=>false }

  class { 'cluster::haproxy_ocf':
    primary_controller => $primary_controller
  }

  package { ['tomcat6', 'midonet-api']:
    ensure => present,
  }
  file { '/etc/tomcat6/server.xml':
    ensure => present,
    content => template('plugin_midonet/server.xml.erb'),
    require => Package['tomcat6'],
  } ->
  file { '/etc/tomcat6/Catalina/localhost/midonet-api.xml':
    ensure => present,
    content => template('plugin_midonet/midonet-api.xml.erb'),
    require => Package['tomcat6'],
  } ->
  file { '/usr/share/midonet-api/WEB-INF/web.xml':
    ensure => present,
    content => template('plugin_midonet/web.xml.erb'),
    require => Package['midonet-api'],
  } ~>
  service { 'tomcat6':
    ensure => running,
    require => Package['midonet-api','tomcat6'],
    #    notify => Exec['/sbin/service tomcat6 restart'],
  }

  Haproxy::Service        { use_include => true }
  Haproxy::Balancermember { use_include => true }

  Openstack::Ha::Haproxy_service {
    server_names        => filter_hash($::controllers, 'name'),
    ipaddresses         => filter_hash($::controllers, 'internal_address'),
    public_virtual_ip   => $::fuel_settings['public_vip'],
    internal_virtual_ip => $::fuel_settings['management_vip'],
  }


  openstack::ha::haproxy_service { 'midonetapi':
    order                  => 199,
    listen_port            => 8081,
    balancermember_port    => 8081,
    define_backups         => true,
    before_start           => true,
    public                 => true,
    haproxy_config_options => {
      'balance'        => 'roundrobin',
      'option'         => ['httplog'],
    },
    balancermember_options => 'check',
  }

  #  exec { '/sbin/service tomcat6 restart':
  #  require => Service['tomcat6'],
  #}

  firewall {'502 Midonet api':
    port => '8081',
    proto => 'tcp',
    action => 'accept',
  }

  #  package { 'midonet-cp2':
  #  reuiqre => Service['tomcat6'],

}

