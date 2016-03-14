.. raw:: pdf

   PageBreak oneColumn


Introduction
============

MidoNet is an Apache licensed production grade network virtualization software
for Infrastructure-as-a-Service (IaaS) clouds. Plugin for Fuel |FuelVer| provides the
puppet manifests to install all the components to deploy easily MidoNet with
Fuel in both lab or production environments.

Fuel MidoNet plugin is capable of deploying MidoNet v2015.06_ on top of Mirantis
OpenStack Fuel version |FuelVer| (including  Maintenance Update 2). There are no
prerequisites to use the MidoNet plugin: MidoNet is Open Source, and the plugin
sets the repositories from where download and install MidoNet packages.

This plugin also supports Midokura Enterprise MidoNet (MEM_) installation by
allowing the user to choose the option from the Fuel Web UI.
The packages are available to download from a password protected-repository.
The needed credentials will be provided_ by Midokura.

Requirements
------------

======================= ===============
Requirement             Version/Comment
======================= ===============
Fuel                    |FuelVer|
MidoNet plugin for Fuel |PluginVer|
======================= ===============

Known Limitations
-----------------

* The plugin has some limitations regarding node count scalability for NSDB
  (Network State Database) and OpenStack Controller role nodes. Once number of
  nodes with such roles have been determined on initial deployment, it can not
  be changed. Compute role nodes are not affected by this limitation, current
  plugin version supports Compute scalability.

* Current version of plugin can only deploy single MidoNet Gareway role node.
  MidoNet itself supports any number of gateway nodes, it is only a plugin
  limitation, additional nodes needs to be set up manually. 

.. _v2015.06: https://github.com/midonet/midonet/tree/stable/v2015.06.2
.. _MEM: http://docs.midokura.com/docs/latest/manager-guide/content/index.html
.. _provided: http://www.midokura.com/mem-eval


Changes in MidoNet plugin |PluginVer|
-------------------------------------

* New features:

 * Support for Fuel 7.0 Maintenance Release 2
 * Added post_install.sh script that sets up Fuel experimental features,
   customized MidoNet roles and custom deployment graph

* Bug fixes:

 * Provided updated python-neutron-plugin-midonet debian package
 * MidoNet BGP gateway role parameters
 * Neutron db creation timeouts
 * Fix some OSTF test scenarios
 * Numerous documentation fixes

