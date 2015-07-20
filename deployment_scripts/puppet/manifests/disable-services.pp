$nodes_hash = hiera('nodes', {})
$roles = node_roles($nodes_hash, hiera('uid'))

$ovs_agent_name = $operatingsystem ? {
  'CentOS' => 'neutron-openvswitch-agent',
  'Ubuntu' => 'neutron-plugin-openvswitch-agent',
}

$l3_agent_name = $operatingsystem ? {
  'CentOS' => 'neutron-l3-agent'
}

$dhcp_agent_name = $operatingsystem ? {
  'CentOS' => 'neutron-dhcp-agent'
}

if member($roles, 'primary-controller') {
  cs_resource { "p_${ovs_agent_name}":
    ensure => absent,
  }
} else {
  service {$ovs_agent_name:
    ensure => stopped,
    enable => false,
  }
}

service {$l3_agent_name:
  ensure => stopped,
  enable => false,
}

service {$dhcp_agent_name:
  ensure => stopped
}

service { 'neutron-server':
  ensure => stopped
}
