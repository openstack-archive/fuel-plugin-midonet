
.. raw:: pdf

   PageBreak oneColumn


Installation Guide
==================

Install the Plugin
------------------

To install the MidoNet Fuel plugin:

#. Download the plugin from the `Fuel Plugin Catalog`_

#. Log into Fuel Master node and install the plugin using the `Fuel CLI`_:

   ::

    # fuel plugins --install midonet-fuel-plugin-4.0-4.0.0-1.noarch.rpm

#. Verify that the plugin is installed correctly:
   ::

    # fuel plugins
    id | name    | version | package_version
    ---|---------|---------|----------------
    9  | midonet | 4.0.1   | 4.0.0

.. _`Fuel Plugin Catalog`: https://www.mirantis.com/products/openstack-drivers-and-plugins/fuel-plugins/
.. _`Fuel CLI`: https://docs.mirantis.com/openstack/fuel/fuel-8.0/user-guide.html#using-fuel-cli
