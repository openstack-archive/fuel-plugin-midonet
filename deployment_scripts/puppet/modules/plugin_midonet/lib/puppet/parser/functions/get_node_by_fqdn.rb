module Puppet::Parser::Functions
  newfunction(:get_node_by_fqdn, :type => :rvalue, :doc => <<-EOS
Return a node (node names are keys) that match the fqdn.
example:
  get_node_by_fqdn($network_metadata_hash, 'test.function.com')
EOS
  ) do |args|
    errmsg = "get_node_by_fqdn($network_metadata_hash, $fqdn)"
    n_metadata, fqdn = args
    raise(Puppet::ParseError, "#{errmsg}: 1st argument should be a hash") if !n_metadata.is_a?(Hash)
    raise(Puppet::ParseError, "#{errmsg}: 1st argument should be a valid network_metadata hash") if !n_metadata.has_key?('nodes')
    raise(Puppet::ParseError, "#{errmsg}: 2nd argument should be an string") if !fqdn.is_a?(String)
    nodes = n_metadata['nodes']
    # Using unrequired node_property bellow -- is a workaround for ruby 1.8
    mynode = nodes.reject {|node_name, node_property| fqdn != node_property['fqdn']}
    raise(Puppet::ArgumentError, "#{errmsg}: No matching node found") if mynode.empty?
    return mynode.values[0]
  end
end
