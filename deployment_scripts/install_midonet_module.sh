#!/bin/bash

osfamily=$(facter osfamily)
if [[ $osfamily == "RedHat" ]]; then

    # Install lsb library to get '$::lsbdistrelease' and '$::lsbmajdistrelease'
    yum -y install redhat-lsb-core git

	# Install epel repo
    yum -y localinstall https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

	# Install Cento5 Vault repos for Java 1.7 OpenJDK and dependencies
    cat <<EOF > /etc/yum.repos.d/Centos5-Vault.repo

[C6.5-base]
name=CentOS-6.5 - Base
baseurl=http://vault.centos.org/6.5/os/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1

[C6.5-updates]
name=CentOS-6.5 - Updates
baseurl=http://vault.centos.org/6.5/updates/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1

[C6.5-extras]
name=CentOS-6.5 - Extras
baseurl=http://vault.centos.org/6.5/extras/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1

[C6.5-contrib]
name=CentOS-6.5 - Contrib
baseurl=http://vault.centos.org/6.5/contrib/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1

[C6.5-centosplus]
name=CentOS-6.5 - CentOSPlus
baseurl=http://vault.centos.org/6.5/centosplus/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1


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

fi

puppet module uninstall puppetlabs-stdlib
puppet module install ripienaar-module_data
puppet module install midonet-cassandra
puppet module install deric-zookeeper
puppet module install puppetlabs-apt
puppet module install puppetlabs-java
puppet module install puppetlabs-tomcat
git clone git://github.com/midonet/puppet-midonet /etc/puppet/modules/midonet
puppet module install --force midonet-neutron
