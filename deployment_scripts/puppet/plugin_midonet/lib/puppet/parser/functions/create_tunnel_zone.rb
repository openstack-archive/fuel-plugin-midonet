#    Copyright 2015 Mirantis, Inc.
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
    newfunction(:create_tunnel_zone, :doc => <<-EOS
                This function creates tunnel zone based on input nodes hash
                EOS
    ) do |argv|
        nodes_hash = argv[0]
        tzone = `midonet-cli -e "create tunnel-zone name default type gre"`.strip
        list_host = `midonet-cli -e "host list"`.split("\n")
        list_host.map! { |line| [line.split(" ")[1],line.split(" ")[3]]}
        list_host = Hash[list_host]
        list_host.each do |uuid,fqdn|
            addr = nodes_hash[fqdn]
            `midonet-cli -e "tunnel-zone #{tzone} add member host #{uuid} address #{addr}"`
        end
    end
end
