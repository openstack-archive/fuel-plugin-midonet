$fuel_settings = parseyaml($astute_settings_yaml)
$m_version = $fuel_settings['midonet']['version']

# MidoNet api manifest
class {'::midonet::repository':
  midonet_repo => "http://repo.midonet.org/midonet/${m_version}/RHEL"
}
