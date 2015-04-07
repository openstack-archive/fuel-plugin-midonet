file { '/root/stop_zookeeper.sh':
  ensure => present,
  content => template('plugin_midonet/stop_zookeeper.sh'),
#  notify => Exec['stop'],
} ~>
exec { 'stop':
  command => '/bin/bash /root/stop_zookeeper.sh',
  refreshonly => true,
}

