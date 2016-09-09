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
