#!/bin/bash

puppet module install puppetlabs-java --version=1.6.0 --ignore-dependencies --force
puppet module install locp-cassandra --version=1.25.2 --ignore-dependencies --force
puppet module install deric-zookeeper --version=0.6.1 --ignore-dependencies --force
puppet module install TubeMogul-curator --version=1.0.1 --ignore-dependencies --force
puppet module install elasticsearch-elasticsearch --version=0.15.1 --ignore-dependencies --force
puppet module install elastic-logstash --version=5.0.3 --ignore-dependencies --force
puppet module install electrical-file_concat --version=1.0.1 --ignore-dependencies --force
puppet module install richardc-datacat --version=0.6.2 --ignore-dependencies --force

# Dirty sed because elk packages and fuel use different sysctl packages

sed -i "s|      sysctl { 'vm|      sysctl::value { 'vm|g" /etc/puppet/modules/elasticsearch/manifests/config.pp

gem install faraday  # This is needed by the midonet providers
gem install netaddr  # This is needed to calculate cidrs
