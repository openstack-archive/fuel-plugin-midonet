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
module Puppet::Parser::Functions
  newfunction(:generate_remote_peers, :type => :rvalue, :doc => <<-EOS
    Generate remote peers according to the input values in the plugin settings
    EOS
  ) do |argv|
      mn_settings = argv[0]
      result = []
      if not mn_settings['remote_ip1'].empty? and not mn_settings['remote_as1'].empty?
          result.push({"as" => mn_settings['remote_as1'], "ip" => mn_settings['remote_ip1']})
      end
      return result
  end
end
