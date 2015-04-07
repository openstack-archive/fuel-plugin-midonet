class plugin_midonet::cassandra {
  package { 'dsc20':
    ensure => present,
  }

  file { '/etc/cassandra/conf/cassandra.yaml':
    ensure => present,
    content => template('plugin_midonet/cassandra.yaml.erb'),
    require => Package['dsc20'],
    notify => Service['cassandra'],
  }

  service { 'cassandra':
    ensure => running,
  }

  firewall {'550 cassandra ports':
    port => '9042',
    proto => 'tcp',
    action => 'accept',
  }
  firewall {'551 cassandra ports':
    port => '7000',
    proto => 'tcp',
    action => 'accept',
  }
  firewall {'552 cassandra ports':
    port => '7199',
    proto => 'tcp',
    action => 'accept',
  }
  firewall {'553 cassandra ports':
    port => '9160',
    proto => 'tcp',
    action => 'accept',
  }
  firewall {'554 cassandra ports':
    port => '59471',
    proto => 'tcp',
    action => 'accept',
  }
}
