Puppet::Type.type(:midonet_host).provide(:ruby) do
    optional_commands :midonet_cli => "midonet-cli"

    def tunnel_zone
        res = ''
        tzones = midonet_cli('-e', "tunnel-zone list").split("\n")
        tzones.each do |zone|
            if zone.split(' ')[3] == resource[:tunnel_zone]
                res = zone.split(' ')[1]
            end
        end
        res
    end

    def hosts
        res = {}
        list_host = midonet_cli('-e', "tunnel-zone #{tunnel_zone} list member").split("\n")
        list_host.each do |line|
            host_id = line.split(' ')[3]
            res[midonet_cli('-e',"show host #{host_id}").split(' ')[3]] = host_id
        end
#        list_host.map! { |line| [line.split(" ")[3],line.split(" ")[1]]}
#        list_host = Hash[list_host]
#        list_host
        res
    end

    def exists?
#        puts "DEBUG!!!", hosts.inspect
        hosts.keys().include?(resource[:name])
    end

    def host_id
      res = ''
      list_host = midonet_cli('-e', "host list").split("\n")
#      puts "HOST_ID", list_host.inspect
      list_host.each do |line|
        if line.split(' ')[3] == resource[:name]
          res = line.split(' ')[1]
          break
        end
      end
      res
    end

    def create
        
#        puts "DEBUG CREATE!!!", hosts.inspect, host_id
#        puts "DEBUG CREATE!!!", "tunnel-zone #{tunnel_zone} add member host #{host_id} address #{resource[:nodes][resource[:name]]}"
        midonet_cli('-e',"tunnel-zone #{tunnel_zone} add member host #{host_id} address #{resource[:nodes][resource[:name]]}")
    end

    def destroy
    end
end
