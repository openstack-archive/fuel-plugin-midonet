#!/bin/bash

osfamily=$(facter osfamily)
if [[ $osfamily == "RedHat" ]]; then

    # Install lsb library to get '$::lsbdistrelease' and '$::lsbmajdistrelease'
    yum -y install redhat-lsb-core git

	# Install Cento5 Vault repos for Java 1.7 OpenJDK and dependencies
    cat <<EOF > /etc/yum.repos.d/Centos5-Vault.repo

[base]
name=CentOS-\$releasever - Base
mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=os
#baseurl=http://mirror.centos.org/centos/\$releasever/os/\$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#released updates
[updates]
name=CentOS-\$releasever - Updates
mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=updates
#baseurl=http://mirror.centos.org/centos/\$releasever/updates/\$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#additional packages that may be useful
[extras]
name=CentOS-\$releasever - Extras
mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=extras
#baseurl=http://mirror.centos.org/centos/\$releasever/extras/\$basearch/
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-\$releasever - Plus
mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=centosplus
#baseurl=http://mirror.centos.org/centos/\$releasever/centosplus/\$basearch/
gpgcheck=0
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#contrib - packages by Centos Users
[contrib]
name=CentOS-\$releasever - Contrib
mirrorlist=http://mirrorlist.centos.org/?release=\$releasever&arch=\$basearch&repo=contrib
#baseurl=http://mirror.centos.org/centos/\$releasever/contrib/\$basearch/
gpgcheck=0
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6


EOF

    cat <<EOF > /etc/yum.repos.d/midonet-third-party.repo
[midonet-third-party]
name=Midonet third party repo
baseurl=http://repo.midonet.org/misc/RHEL/6/misc
enabled=1
gpgcheck=1
gpgkey=http://repo.midonet.org/packages.midokura.key
timeout=60
EOF

    # Need to set these steps for a default zookeeper installation
    yum install -y java-1.7.0-openjdk
    mkdir -p /usr/java
    ln -s /etc/alternatives/jre_1.7.0 /usr/java/default
else
    apt-get install -y ruby-dev
fi

gem install json
gem install faraday

puppet module install ripienaar-module_data --force
puppet module install puppetlabs-java --ignore-dependencies --force
puppet module install puppetlabs-apt --ignore-dependencies --force
puppet module install midonet-cassandra --ignore-dependencies --force
puppet module install richardc-datacat --force
puppet module install deric-zookeeper --ignore-dependencies --force
puppet module install puppetlabs-concat --ignore-dependencies --force
puppet module install nanliu-staging --ignore-dependencies --force
puppet module install puppetlabs-tomcat --ignore-dependencies --force
puppet module install midonet-midonet --ignore-dependencies --force

if [[ ! -a /etc/puppet/modules/neutron/manifests/plugins/midonet.pp ]]; then
  # Apply the released patch of Neutron Puppet to allow midonet manifests
  wget https://github.com/openstack/puppet-neutron/commit/5e034e2af7ecb31cfcb758c7f43f47e46ce5677a.diff -O /etc/puppet/modules/neutron/midonet.diff
  cd /etc/puppet/modules/neutron && patch -p1 < midonet.diff && cd -
fi
