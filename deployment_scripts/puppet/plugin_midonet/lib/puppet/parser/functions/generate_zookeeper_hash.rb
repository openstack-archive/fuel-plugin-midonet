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
