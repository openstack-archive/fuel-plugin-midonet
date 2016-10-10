#    Copyright 2015 Midokura SARL, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

require 'csv'
require 'netaddr'

module Puppet::Parser::Functions
  newfunction(:generate_bgp_edge_subnet_hash, :type => :rvalue, :doc => <<-EOS
    This function generates a Hash to create the neutron subnet resources for BGP
    on the edge router
    EOS
  ) do |argv|
    result = {}
    list_of_neighbors = argv[0].split(',')
    list_of_neighbors.each do |neighbor|
      ip_netnl = neighbor.split('-')[0]
      cidr = NetAddr::CIDR.create(ip_netnl).to_s
      subnet_name = 'edge-subnet-' + cidr.gsub('.','').gsub("/","")
      result[subnet_name] = {
        'cidr' => NetAddr::CIDR.create(ip_netnl).to_s
      }
    end

    return result
  end
end
