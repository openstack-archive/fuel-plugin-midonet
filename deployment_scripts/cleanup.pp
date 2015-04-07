file { '/etc/yum.repos.d/CentOS-Base.repo':
  ensure => absent,
}

file { '/etc/yum.repos.d/epel.repo':
  ensure => absent,
}
