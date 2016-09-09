#!/bin/bash

#install git
apt-get install -y git

cd /tmp
git clone https://github.com/midonet/puppet-midonet_openstack.git
cd puppet-midonet_openstack
git fetch
puppet module build
puppet module install $(find . | grep .tar.gz) --ignore-dependencies --force

#cleanup
rm -rf /tmp/puppet-midonet_openstack
