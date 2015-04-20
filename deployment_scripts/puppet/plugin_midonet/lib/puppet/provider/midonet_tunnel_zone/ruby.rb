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

Puppet::Type.type(:midonet_tunnel_zone).provide(:ruby) do
    optional_commands :midonet_cli => "midonet-cli"
   
    def exists?
        tunnel_zones = midonet_cli('-e', "tunnel-zone list").split("\n")
        tunnel_zones.map! { |line| [line.split(" ")[1],line.split(" ")[3]]}
        tunnel_zones = Hash[tunnel_zones]
        tunnel_zones.values().include?(resource[:name])
    end
    def create
        midonet_cli('-e',"create tunnel-zone name #{resource[:name]} type gre")
    end
    def destroy
    end
end
