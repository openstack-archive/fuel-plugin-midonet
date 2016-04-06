exec { 'drop_neutron_db':
  command => "mysql -e 'drop database if exists neutron;'",
  path    => '/usr/bin',
  unless  => 'mysql neutron -e "SELECT * FROM midonet LIMIT 1;"'
}

exec { 'create_neutron_db':
  command => "mysql -e 'create database neutron character set utf8;'",
  path    => '/usr/bin',
  unless  => 'mysqlshow neutron'
}

exec { 'grant_neutron_db':
  command => "mysql -e \"grant all on neutron.* to 'neutron'@'%';\"",
  path    => '/usr/bin',
  unless  => 'mysql neutron -e "SELECT * FROM midonet LIMIT 1;"'
}

exec { 'neutron_db_sync':
  command => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head',
  path    => '/usr/bin',
  unless  => 'mysql neutron -e "SELECT * FROM midonet LIMIT 1;"',
  timeout => 500
}

exec { 'stamp_midonet':
  command => 'mysql neutron -e "CREATE TABLE IF NOT EXISTS midonet (this_is_midonet_neutron_db BOOL);"',
  path    => '/usr/bin'
}

Exec['drop_neutron_db'] -> Exec['create_neutron_db'] -> Exec['grant_neutron_db'] -> Exec['neutron_db_sync'] -> Exec['stamp_midonet']
