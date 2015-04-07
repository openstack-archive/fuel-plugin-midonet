class plugin_midonet::compute_neutron {
  $neutron_config = $::fuel_settings['quantum_settings']
  class { 'nova::compute::neutron':
  }

  class { 'nova::network::neutron':
    neutron_admin_password          => $neutron_config['keystone']['admin_password'],
    neutron_url                     => "http://${::service_endpoint}:9696",
    neutron_admin_auth_url          => "http://${::service_endpoint}:35357/v2.0",
  }

  service {'openstack-nova-compute':
    ensure => running,
  }
  Nova_config <||> ~> Service['openstack-nova-compute']
  service { 'libvirt':
    name => 'libvirtd',
    ensure => running,
  }

  file_line { 'user_root':
    path    => '/etc/libvirt/qemu.conf',
    line    => 'user = "root"',
    notify  => Service['libvirt']
  }
  file_line { 'group_root':
    path    => '/etc/libvirt/qemu.conf',
    line    => 'group = "root"',
    notify  => Service['libvirt']
  }
  file_line { 'cgroup_controllers':
    path    => '/etc/libvirt/qemu.conf',
    line    => 'cgroup_controllers = [ "cpu", "devices", "memory", "blkio", "cpuset", "cpuacct" ]',
    notify  => Service['libvirt']
  }
  file_line { 'clear_emulator_capabilities':
    path    => '/etc/libvirt/qemu.conf',
    line    => 'clear_emulator_capabilities = 0',
    notify  => Service['libvirt']
  }

  file_line { 'cgroup_device_acl':
    path    => '/etc/libvirt/qemu.conf',
    line    => 'cgroup_device_acl = [
     "/dev/null", "/dev/full", "/dev/zero",
     "/dev/random", "/dev/urandom",
     "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
     "/dev/rtc","/dev/hpet", "/dev/vfio/vfio",
     "/dev/net/tun"
  ]',
    notify  => Service['libvirt']
  }

}
