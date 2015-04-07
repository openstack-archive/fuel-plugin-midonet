class plugin_midonet::params {
  $zoo_hosts = generate_zookeeper_hash($::fuel_settings['nodes'],'midonet-gw')
}
