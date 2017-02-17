
.. raw:: pdf

   PageBreak oneColumn

.. _installation_guide:

Installation Guide
==================

Install the Plugin
------------------

To install the MidoNet Fuel plugin:

#. Download the plugin from the `Partner Community Catalog`_

#. Log into Fuel Master node and install the plugin using the `Fuel CLI`_:

   ::

    # fuel plugins --install midonet-9.2-9.2.0-1.noarch.rpm

#. Verify that the plugin is installed correctly:
   ::

    # fuel plugins
    id | name    | version | package_version | releases
    ---+---------+---------+-----------------+--------------------
    1  | midonet | 9.2.0   | 4.0.0           | ubuntu (mitaka-9.0)


.. _`Partner Community Catalog`: https://www.mirantis.com/partners/midokura/
.. _`Fuel CLI`: http://docs.openstack.org/developer/fuel-docs/userdocs/fuel-user-guide/cli.html
