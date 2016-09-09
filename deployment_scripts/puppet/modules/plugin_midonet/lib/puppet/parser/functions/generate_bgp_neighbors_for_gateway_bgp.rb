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
  newfunction(:generate_bgp_neighbors_for_gateway_bgp, :type => :rvalue, :doc => <<-EOS
    This function generates a Hash to create the neutron subnet resources for BGP
    on the edge router
    EOS
  ) do |argv|
    result = []
    split_list_of_neighbors = argv[0].split(',')
    split_list_of_neighbors.each do |neighbor|
      split_neighbor = neighbor.split('-')
      remote_net = NetAddr::CIDR.create(split_neighbor[0]).to_s
      ip_address = split_neighbor[1]
      remote_asn = split_neighbor[2]
      result.push (
        {
          'ip_address' => ip_address,
          'remote_asn' => remote_asn,
          'remote_net' => remote_net
        }
      )
    end

    return result
  end
end
