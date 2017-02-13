if [[ -e /etc/puppet/modules/neutron/lib/puppet/type/neutron_plugin_midonet.rb ]]; then
  # Apply the released patch of Neutron Puppet to allow midonet manifests
  wget https://github.com/openstack/puppet-neutron/commit/dfd4662347bec58644c6f22bf9ba2a433c23b4d9.diff -O /etc/puppet/modules/neutron/midonet.diff
  cd /etc/puppet/modules/neutron && patch -p1 --force --forward < midonet.diff  && cd -
fi

# Dirty way of checking if the neutron type is already patched. It is not possible to get
# version Of the current fuel version from a node.
NEUTRONTYPEPATCHED=$(cat /etc/puppet/modules/neutron/lib/puppet/type/neutron_port.rb | grep binding_host_id | head -n1)
if [[ -z ${NEUTRONTYPEPATCHED} ]]; then
  if [[ -e /etc/puppet/modules/neutron/lib/puppet/provider/neutron_port/neutron.rb ]]; then
    # Apply the released patch of Neutron Puppet to allow midonet manifests
    wget https://github.com/openstack/puppet-neutron/commit/dcfb3dd946cbc6f6083afa35f023917dfe0369e4.diff -O /etc/puppet/modules/neutron/midonet2.diff
    cd /etc/puppet/modules/neutron && patch -p1 --force  --forward < midonet2.diff  && cd -
  fi
fi

if [[ -e /etc/puppet/modules/neutron/lib/puppet/type/neutron_network.rb ]]; then
  # Apply the released patch of Neutron Puppet to allow midonet manifests
  wget https://github.com/openstack/puppet-neutron/commit/95f0514a8ef6f5491d7e5775553d234435354cf8.diff -O /etc/puppet/modules/neutron/midonet3.diff
  cd /etc/puppet/modules/neutron && patch -p1 --force --forward < midonet3.diff  && cd -
fi


if [[ -e /etc/puppet/modules/neutron/lib/puppet/provider/neutron.rb ]]; then
  # Apply the released patch of Neutron Puppet to allow midonet manifests
  wget https://github.com/openstack/puppet-neutron/commit/46e2d7acdcd5319bbc73483ff24cbafa0409d302.diff -O /etc/puppet/modules/neutron/midonet4.diff
  cd /etc/puppet/modules/neutron && patch -p1 --force --forward < midonet4.diff  && cd -
fi

if [[ -e /etc/puppet/modules/neutron/manifests/plugins/midonet.pp ]]; then
  # Apply the released patch of Neutron Puppet to allow midonet manifests
  wget https://github.com/openstack/puppet-neutron/commit/e4a79e348d110e7a80e042a045a671359f31c103.diff -O /etc/puppet/modules/neutron/midonet5.diff
  cd /etc/puppet/modules/neutron && patch -p1 --force --forward < midonet5.diff && cd -
fi

if [[ -e /etc/puppet/modules/neutron/manifests/plugins/midonet.pp ]]; then
  # Apply the released patch of Neutron Puppet to allow midonet manifests
  wget https://github.com/openstack/puppet-neutron/commit/3af5e9a40400bc7dc47cd7c265b5f126637c4ba3.diff -O /etc/puppet/modules/neutron/midonet6.diff
  cd /etc/puppet/modules/neutron && patch -p1 --force --forward < midonet6.diff && cd -
fi

exit 0
