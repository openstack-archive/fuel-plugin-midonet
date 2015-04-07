$fuel_settings = parseyaml($astute_settings_yaml)
$nodes_hash = $::fuel_settings['nodes']
$primary_controller_nodes = filter_nodes($nodes_hash,'role','primary-controller')
$controllers = concat($primary_controller_nodes, filter_nodes($nodes_hash,'role','controller'))
$service_endpoint              = $::fuel_settings['management_vip']
stage { 'repos':
    before => Stage['main']
}


class {'plugin_midonet::repos':
    stage => repos,
}

class {'plugin_midonet::midonetapi':
}

