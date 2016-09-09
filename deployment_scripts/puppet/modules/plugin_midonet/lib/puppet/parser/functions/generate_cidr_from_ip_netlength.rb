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

require 'netaddr'

module Puppet::Parser::Functions
  newfunction(:generate_cidr_from_ip_netlength, :type => :rvalue, :doc => <<-EOS
    This function returns BGP cidr CSV as an array
    EOS
  ) do |argv|
    result = NetAddr::CIDR.create(argv[0]).to_s
    return result
  end
end
