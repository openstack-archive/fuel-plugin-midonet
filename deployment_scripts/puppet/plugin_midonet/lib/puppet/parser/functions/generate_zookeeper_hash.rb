#    Copyright 2013 Mirantis, Inc.
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

module Puppet::Parser::Functions
  newfunction(:generate_zookeeper_hash, :type => :rvalue, :doc => <<-EOS
    This function returns Zookeper configuration hash
    EOS
  ) do |argv|
    nodes_hash = argv[0]
    role = argv[1]
    result = {}
    ip_list = []
    sorted_ctrls = nodes_hash.select { |node| node["role"] == role }
    sorted_ctrls.sort! {|a,b| a['uid'].to_i <=> b['uid'].to_i}
#    sorted_ctrls = nodes_hash.select { |node| node["role"] == 'primary-controller' } + sorted_ctrls
    sorted_ctrls.each do |ctrl|
        result[ctrl['fqdn']] = { 'address' => ctrl['internal_address'],
                                 'id' => sorted_ctrls.index(ctrl)+1
                               }
    end
    return result
  end
end
