Mirantis Fuel MidoNet plugin
============================

Compatible versions:

- Mirantis Fuel 7.0
- MidoNet v2015.6
- Midokura Enterprise MidoNet 1.9

How to build the plugin:

- Install Fuel plugin builder (fpb)

  ::

   # pip install fuel-plugin-builder

- Clone the plugin repo and run fpb there:

  ::

   $ git clone https://github.com/openstack/fuel-plugin-midonet
   $ cd fuel-plugin-midonet
   $ fpb --build .

- Check if file midonet-fuel-plugin-3.0-3.0.1-1.noarch.rpm was created.

  ::

   $ fuel plugins
   id | name                | version | package_version
   ---|---------------------|---------|----------------
   1  | midonet-fuel-plugin | 3.0.1   | 3.0.0          

Please refer to `Plugin Guide <./doc/user-guide.rst>`_ for documentation
