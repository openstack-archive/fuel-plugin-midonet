#!/bin/bash

#install git
apt-get install -y git


cd /tmp
git clone https://github.com/openstack/puppet-midonet.git
cd puppet-midonet
puppet module build
puppet module install $(find . | grep .tar.gz) --ignore-dependencies --force

#cleanup
rm -rf /tmp/puppet-midonet
