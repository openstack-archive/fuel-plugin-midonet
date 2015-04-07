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
