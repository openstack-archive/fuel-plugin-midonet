# Copyright 2015 Midokura SARL, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
require 'ipaddr'

module Puppet::Parser::Functions
  newfunction(:public_network_hash, :type => :rvalue, :doc => <<-EOS
    This function returns a network address and an integer mask based
    on and IP address of the network and its IP mask
    EOS
  ) do |argv|
      ip = argv[0]
      netmask = argv[1]
      result = {}
      result['network_address'] = IPAddr.new(ip).mask(netmask).to_s
      result['mask'] = IPAddr.new(netmask).to_i.to_s(2).count("1").to_s
      return result
  end
end
