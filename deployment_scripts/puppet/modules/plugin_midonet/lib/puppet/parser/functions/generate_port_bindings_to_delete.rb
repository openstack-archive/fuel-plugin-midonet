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
  newfunction(:generate_port_bindings_to_delete, :type => :rvalue, :doc => <<-EOS
    This function returns the port bindings to delete for create_resources
    EOS
  ) do |argv|
    controllers_map = argv[0]
    result = {}
    controllers_map.each do |key,value|
      port_name = 'port-static-' + value['fqdn']
      result[port_name] = {
        'binding_host_id' => value['fqdn']
      }
    end

    return result
  end
end
