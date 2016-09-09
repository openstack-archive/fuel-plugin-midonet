#!/bin/bash

puppet module install puppetlabs-java --version=1.6.0 --ignore-dependencies --force
puppet module install locp-cassandra --version=1.25.2 --ignore-dependencies --force
puppet module install deric-zookeeper --version=0.6.1 --ignore-dependencies --force
puppet module install TubeMogul-curator --version=1.0.1 --ignore-dependencies --force
puppet module install elasticsearch-elasticsearch --version=0.13.2 --ignore-dependencies --force
puppet module install elasticsearch-logstash --version=0.6.4 --ignore-dependencies --force
puppet module install electrical-file_concat --version=1.0.1 --ignore-dependencies --force
puppet module install richardc-datacat --version=0.6.2 --ignore-dependencies --force

gem install faraday  # This is needed by the midonet providers


if [[ ! -a /etc/puppet/modules/neutron/lib/puppet/type/neutron_plugin_midonet.rb ]]; then
  # Apply the released patch of Neutron Puppet to allow midonet manifests
  wget https://github.com/openstack/puppet-neutron/commit/dfd4662347bec58644c6f22bf9ba2a433c23b4d9.diff -O /etc/puppet/modules/neutron/midonet.diff
  cd /etc/puppet/modules/neutron && patch -p1 < midonet.diff && cd -
fi

if [[ ! -a lib/puppet/provider/neutron_port/neutron.rb ]]; then
  # Apply the released patch of Neutron Puppet to allow midonet manifests
  wget https://github.com/openstack/puppet-neutron/commit/dcfb3dd946cbc6f6083afa35f023917dfe0369e4.diff -O /etc/puppet/modules/neutron/midonet2.diff
  cd /etc/puppet/modules/neutron && patch -p1 < midonet2.diff && cd -
fi

if [[ ! -a lib/puppet/type/neutron_network.rb ]]; then
  # Apply the released patch of Neutron Puppet to allow midonet manifests
  wget https://github.com/openstack/puppet-neutron/commit/95f0514a8ef6f5491d7e5775553d234435354cf8.diff -O /etc/puppet/modules/neutron/midonet3.diff
  cd /etc/puppet/modules/neutron && patch -p1 < midonet3.diff && cd -
fi


if [[ ! -a /etc/puppet/modules/neutron/lib/puppet/provider/neutron.rb ]]; then
  # Apply the released patch of Neutron Puppet to allow midonet manifests
  wget https://github.com/openstack/puppet-neutron/commit/46e2d7acdcd5319bbc73483ff24cbafa0409d302.diff -O /etc/puppet/modules/neutron/midonet4.diff
  cd /etc/puppet/modules/neutron && patch -p1 < midonet4.diff && cd -
fi

if [[ ! -a /etc/puppet/modules/neutron/manifests/plugins/midonet.pp ]]; then
  # Apply the released patch of Neutron Puppet to allow midonet manifests
  wget https://github.com/openstack/puppet-neutron/commit/e4a79e348d110e7a80e042a045a671359f31c103.diff -O /etc/puppet/modules/neutron/midonet5.diff
  cd /etc/puppet/modules/neutron && patch -p1 < midonet5.diff && cd -
fi

if [[ ! -a /etc/puppet/modules/neutron/manifests/plugins/midonet.pp ]]; then
  # Apply the released patch of Neutron Puppet to allow midonet manifests
  wget https://github.com/openstack/puppet-neutron/commit/3af5e9a40400bc7dc47cd7c265b5f126637c4ba3.diff -O /etc/puppet/modules/neutron/midonet6.diff
  cd /etc/puppet/modules/neutron && patch -p1 < midonet6.diff && cd -
fi
