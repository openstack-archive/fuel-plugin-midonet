.. |FuelVer|        replace:: 9.0/9.1
.. |PrevPluginVer|  replace:: 4.0.0
.. |PluginVer|      replace:: 4.1.0

.. raw:: pdf

   PageBreak oneColumn


Introduction
============

MidoNet is an Apache licensed production grade network virtualization software
for Infrastructure-as-a-Service (IaaS) clouds. Plugin for Fuel |FuelVer| provides the
puppet manifests to install all the components to deploy easily MidoNet with
Fuel in both lab or production environments.

Fuel MidoNet plugin is capable of deploying MidoNet v5.2_ on top of Mirantis
OpenStack Fuel version |FuelVer|. There are no prerequisites to use the MidoNet
plugin: MidoNet is Open Source, and the plugin sets the repositories from where
download and install MidoNet packages.

This plugin also supports installation of same version of Midokura Enterprise
MidoNet (MEM_) by allowing the user to choose the option from the Fuel Web UI.
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

.. _known_limitations:

Known Limitations
-----------------

* The plugin has some limitations regarding node count regarding
  Analytics/Insight MEM-only feature. Currently, only one such node can be
  deployed.

.. _v5.2: https://github.com/midonet/midonet/tree/v5.2.1
.. _MEM: http://docs.midokura.com/docs/latest/manager-guide/content/index.html
.. _provided: http://www.midokura.com/mem-eval


Changes in MidoNet plugin |PluginVer|
-------------------------------------

New features:

 * Support for MidoNet 5.2 including all MEM features
 * Support for Fuel |FuelVer|
 * support for deploying MidoNet manager web-app on controller nodes
 * Support for arbitrary number of BGP gateway nodes
 * Support for static, non-BGP gateway







