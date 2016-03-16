notice('MODULAR: midonet-override-hiera.pp')

file {'/etc/hiera/plugins/midonet-fuel-plugin.yaml':
    ensure => file,
    source => '/etc/fuel/plugins/midonet-fuel-plugin-4.0/puppet/files/midonet-fuel-plugin.yaml'
}
