$service_path = $operatingsystem ? {
  'CentOS' => '/sbin',
  'Ubuntu' => '/usr/bin:/usr/sbin:/sbin:/bin'
}

exec {'service midolman stop':
  path   => $service_path
} ->

exec {'/usr/bin/mm-dpctl --delete-dp ovs-system':
  path   => "/usr/bin:/usr/sbin:/bin",
  onlyif => '/usr/bin/mm-dpctl --show-dp ovs-system'
} ->

exec {'/usr/bin/mm-dpctl --delete-dp midonet':
  path   => "/usr/bin:/usr/sbin:/bin",
  onlyif => '/usr/bin/mm-dpctl --show-dp midonet'
} ->

exec {'sleep 3':
  path => $service_path
} ->

exec {'service midolman start':
  path   => $service_path
}
