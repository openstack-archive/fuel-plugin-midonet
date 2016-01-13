# Extract data from hiera
$api_ip      = hiera('management_vip')
$access_data = hiera_hash('access')
$username    = $access_data['user']
$password    = $access_data['password']
$tenant_name = $access_data['tenant']

# Plugin settings data
$midonet_settings = hiera_hash('midonet-fuel-plugin')
$tz_type = $midonet_settings['tunnel_type']

$service_path = $operatingsystem ? {
  'CentOS' => '/sbin',
  'Ubuntu' => '/usr/bin:/usr/sbin:/sbin'
}

# Somehow, there are times where the hosts don't register
# to NSDB. Restarting midolman forces the registration
exec {'service midolman restart':
  path   => $service_path
} ->

midonet_host_registry {$::fqdn:
  midonet_api_url     => "http://${api_ip}:8081",
  username            => $username,
  password            => $password,
  tenant_name         => $tenant_name,
  underlay_ip_address => $::ipaddress_br_mesh,
  tunnelzone_type     => $tz_type,
  tunnelzone_name     => 'tzonefuel',
  ensure              => present
}
