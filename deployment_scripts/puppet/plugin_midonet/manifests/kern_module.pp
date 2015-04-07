define plugin_midonet::kern_module ($ensure) {
    $modulesfile = $operatingsystem ? { debian => "/etc/modules", redhat => "/etc/rc.modules", centos=>"/etc/rc.modules" }
    case $operatingsystem {
        redhat: { file { "/etc/rc.modules": ensure => file, mode => 755 } }
        centos: { file { "/etc/rc.modules": ensure => file, mode => 755 } }
    }
    case $ensure {
        present: {
            exec { "insert_module_${name}":
                command => $operatingsystem ? {
                    debian => "/bin/echo '${name}' >> '${modulesfile}'",
                    redhat => "/bin/echo '/sbin/modprobe ${name}' >> '${modulesfile}' ",
                    centos => "/bin/echo '/sbin/modprobe ${name}' >> '${modulesfile}' "
                },
                unless => $operatingsystem ? {
                    debian => "/bin/grep -qFx '${name}' '${modulesfile}'",
                    redhat => "/bin/grep -q '^/sbin/modprobe ${name}\$' '${modulesfile}'",
                    centos => "/bin/grep -q '^/sbin/modprobe ${name}\$' '${modulesfile}'",
                }
            }
            exec { "/sbin/modprobe ${name}": unless => "/bin/grep -q '^${name} ' '/proc/modules'" }
        }
        absent: {
            exec { "/sbin/modprobe -r ${name}": onlyif => "/bin/grep -q '^${name} ' '/proc/modules'" }
            exec { "remove_module_${name}":
                command => $operatingsystem ? {
                    debian => "/usr/bin/perl -ni -e 'print unless /^\\Q${name}\\E\$/' '${modulesfile}'",
                    redhat => "/usr/bin/perl -ni -e 'print unless /^\\Q/sbin/modprobe ${name}\\E\$/' '${modulesfile}'",
                    centos => "/usr/bin/perl -ni -e 'print unless /^\\Q/sbin/modprobe ${name}\\E\$/' '${modulesfile}'"
                },
                onlyif => $operatingsystem ? {
                    debian => "/bin/grep -qFx '${name}' '${modulesfile}'",
                    redhat => "/bin/grep -q '^/sbin/modprobe ${name}\$' '${modulesfile}'",
                    centos => "/bin/grep -q '^/sbin/modprobe ${name}\$' '${modulesfile}'"
                }
            }
        }
        default: { err ( "unknown ensure value ${ensure}" ) }
    }
}
