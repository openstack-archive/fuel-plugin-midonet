$fuel_settings = parseyaml($astute_settings_yaml)
$service_endpoint = $::fuel_settings['management_vip']
class { 'plugin_midonet::compute_neutron': }
