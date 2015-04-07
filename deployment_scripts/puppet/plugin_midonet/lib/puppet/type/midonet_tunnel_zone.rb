Puppet::Type.newtype(:midonet_tunnel_zone) do

  ensurable

  newparam(:name, :namevar => true) do
    desc 'FQDN of midonet host'
  end
end
