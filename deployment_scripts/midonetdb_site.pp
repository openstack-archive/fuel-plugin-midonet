$fuel_settings = parseyaml($astute_settings_yaml)
$nodes_hash = $::fuel_settings['nodes']
$node = filter_nodes($nodes_hash,'name',$::hostname)
$internal_address = $node[0]['internal_address']
$gateways = filter_nodes($nodes_hash,'role','midonet-gw')
$gateways_internal_addresses = nodes_to_hash($gateways,'name','internal_address')

stage { 'repos':
} ->
stage { 'zookeeper':
} ->
stage { 'cassandra':
  before => Stage['main']
}

class {'plugin_midonet::repos':
    stage => repos,
}
class {'plugin_midonet::zookeeper':
    stage => zookeeper,
}
class {'plugin_midonet::cassandra':
    stage => cassandra,
}

