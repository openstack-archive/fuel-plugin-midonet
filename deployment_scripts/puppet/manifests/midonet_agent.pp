$fuel_settings = parseyaml($astute_settings_yaml)
$all_nodes = $fuel_settings['nodes']
$nsdb_nodes = filter_nodes($all_nodes, 'role', 'nsdb')
$zoo_ips = generate_api_zookeeper_ips($nsdb_nodes)
$cass_hash = nodes_to_hash($nsdb_nodes, 'name', 'internal_address')
$api_ip = $::fuel_settings['management_vip']

$m_version = $::fuel_settings['midonet']['version']
$tz_type = $::fuel_settings['midonet']['tunnel_type']
$username = $fuel_settings['access']['user']
$password = $fuel_settings['access']['password']
$tenant_name = $fuel_settings['access']['tenant']

# MidoNet api manifest
class {'::midonet::repository':
  midonet_repo => "http://repo.midonet.org/midonet/${m_version}/RHEL"
} ->

class {'::midonet::midonet_agent':
  zk_servers      => $zoo_ips,
  cassandra_seeds => values($cass_hash)
} ->

class {'::midonet::midonet_cli':
  api_endpoint => "http://${api_ip}:8081/midonet-api",
  username     => $username,
  password     => $password,
  tenant_name  => $tenant_name
}

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
