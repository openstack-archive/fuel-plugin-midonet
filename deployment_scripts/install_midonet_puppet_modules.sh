#!/bin/bash

puppet module install ripienaar-module_data --version=0.0.3 --force
puppet module install puppetlabs-java --version=1.4.1 --ignore-dependencies --force
puppet module install midonet-cassandra --version=1.0.4 --ignore-dependencies --force
puppet module install deric-zookeeper --version=0.3.9 --ignore-dependencies --force
puppet module install puppetlabs-tomcat --version=1.3.2 --ignore-dependencies --force
puppet module install midonet-midonet --version=2015.6.7 --ignore-dependencies --force
