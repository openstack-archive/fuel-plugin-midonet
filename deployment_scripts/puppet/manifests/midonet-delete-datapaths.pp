exec {'service midolman stop':
  path   => '/sbin'
} ->

exec {'/usr/bin/mm-dpctl --delete-dp ovs-system':
  path   => "/usr/bin:/usr/sbin:/bin",
  onlyif => '/usr/bin/mm-dpctl --show-dp ovs-system'
} ->

exec {'/usr/bin/mm-dpctl --delete-dp midonet':
  path   => "/usr/bin:/usr/sbin:/bin",
  onlyif => '/usr/bin/mm-dpctl --show-dp midonet'
} ->

exec {'service midolman start':
  path   => '/sbin'
}
