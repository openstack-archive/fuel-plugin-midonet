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
