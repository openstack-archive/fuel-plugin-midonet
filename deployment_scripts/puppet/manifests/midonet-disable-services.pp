$nodes_hash = hiera('nodes', {})
$roles = node_roles($nodes_hash, hiera('uid'))

$ovs_agent_name = $operatingsystem ? {
  'CentOS' => 'neutron-openvswitch-agent',
  'Ubuntu' => 'neutron-plugin-openvswitch-agent',
}

$l3_agent_name = $operatingsystem ? {
  'CentOS' => 'neutron-l3-agent',
  'Ubuntu' => 'neutron-l3-agent'
}

$dhcp_agent_name = $operatingsystem ? {
  'CentOS' => 'neutron-dhcp-agent',
  'Ubuntu' => 'neutron-dhcp-agent'
}

$metadata_agent_name = $operatingsystem ? {
  'CentOS' => 'neutron-metadata-agent',
  'Ubuntu' => 'neutron-metadata-agent'
}

if member($roles, 'primary-controller') {
  cs_resource { "p_${ovs_agent_name}":
    ensure => absent,
  }
  exec {'stop-dhcp-agent':
    command   => 'crm resource stop p_neutron-dhcp-agent',
    path      => '/usr/bin:/usr/sbin'
  } ->
  exec {'stop-metadata-agent':
    command   => 'crm resource stop p_neutron-metadata-agent',
    path      => '/usr/bin:/usr/sbin'
  } ->
  exec {'stop-l3-agent':
    command   => 'crm resource stop p_neutron-l3-agent',
    path      => '/usr/bin:/usr/sbin'
  }
} else {
  service {$ovs_agent_name:
    ensure => stopped,
    enable => false,
  }

  service {$l3_agent_name:
    ensure => stopped,
    enable => false,
  }

  service {$dhcp_agent_name:
    ensure => stopped
  }

  service {$metadata_agent_name:
    ensure => stopped
  }
}


service { 'neutron-server':
  ensure => stopped
}
