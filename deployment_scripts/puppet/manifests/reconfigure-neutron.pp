$fuel_settings = parseyaml($astute_settings_yaml)
$address = hiera('management_vip')
$m_version = $fuel_settings['midonet']['version']

# MidoNet api manifest
class {'::midonet::repository':
  midonet_repo => "http://repo.midonet.org/midonet/${m_version}/RHEL"
} ->

class {'::midonet_neutron_plugin':
  midonet_api_ip   => $address,
  midonet_api_port => 8081,
  keystone_username => 'admin',
  keystone_password => $::fuel_settings['keystone']['admin_token'],
  keystone_tenant => 'admin',
  sync_db => true
}
