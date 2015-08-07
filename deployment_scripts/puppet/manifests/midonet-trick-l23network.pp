# Create a file to trick the l23network and let install
# openvswitch module to configure the public interface
file {"/etc/hiera/override":
  ensure => directory
} ->

file {"/etc/hiera/override/node":
  ensure => directory
} ->

file {"/etc/hiera/override/node/${::fqdn}.yaml":
  ensure  => present,
  content => "use_neutron: true\n"
}
