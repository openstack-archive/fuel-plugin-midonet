Mirantis Fuel MidoNet plugin
============================

Compatible versions:

- Mirantis Fuel 7.0
- MidoNet v2015.6
- Midokura Enterprise MidoNet 1.9

How to build the plugin:

- Install fuel plugin builder (fpb)
- Clone the plugin repo and run fpb there:

  git clone https://github.com/openstack/fuel-plugin-midonet
  cd fuel-plugin-midonet/
  fpb --build .
- Check if file midonet-fuel-plugin-3.0-3.0.0-1.noarch.rpm was created.

Please refer to `Plugin Guide <./doc/user-guide.rst>`_ for documentation
