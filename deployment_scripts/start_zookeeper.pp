file { '/tmp/start_zookeeper.sh':
  ensure => present,
  content => template('plugin_midonet/start_zookeeper.sh'),
} ->
exec { '/bin/bash /tmp/start_zookeeper.sh':
}


