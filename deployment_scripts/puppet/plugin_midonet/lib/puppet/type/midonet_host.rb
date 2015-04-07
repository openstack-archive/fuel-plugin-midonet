Puppet::Type.newtype(:midonet_host) do

  ensurable

  newparam(:name, :namevar => true) do
    desc 'FQDN of midonet host'
  end

  newparam(:nodes) do
    desc 'Midonet nodes hash { fqdn => ip }'
  end

  newparam(:tunnel_zone) do
    desc 'Tunnel zone name'
  end
end
