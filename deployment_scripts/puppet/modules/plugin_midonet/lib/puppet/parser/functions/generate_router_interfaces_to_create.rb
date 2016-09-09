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

module Puppet::Parser::Functions
  newfunction(:generate_router_interfaces_to_create, :type => :rvalue, :doc => <<-EOS
    This function returns the port bindings to create to pass to the shell script
    Since you can't send an array to a bash script, let's send a CSV instead.
    EOS
  ) do |argv|
    result = ''
    list_of_neighbors = argv[0].split(',')
    list_of_ports = list_of_neighbors.collect { |x| 'edge-port-' + x.split('-')[0].split('/')[0].gsub('.','') }.uniq
    list_of_ports.each do |port|
      result << port + ','
    end

    return result.chop
  end
end
