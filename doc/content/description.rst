MidoNet Plugin for Fuel 7.0
===========================

MidoNet is an Apache licensed production grade network virtualization software
for Infrastructure-as-a-Service (IaaS) clouds. This plugin provides the puppet
manifests to install all the components to deploy easily MidoNet with Fuel in a
production environment.

MidoNet version that will be deployed is v2015.06_ and this plugin currently is
only compatible with version 7.0 of Mirantis OpenStack Fuel.

There are no prerequisites to use the MidoNet plugin: MidoNet is Open Source,
and the plugin sets the repositories from where download and install MidoNet
packages.

This plugin also supports Midokura Enterprise MidoNet `(MEM)`_ installation by
allowing the user to choose the option from the Fuel Web UI.
The packages are available to download from a password protected-repository.
The needed credentials will be provided_ by Midokura.

Requirements
------------

======================= ===============
Requirement             Version/Comment
======================= ===============
Fuel                    7.0
MidoNet plugin for Fuel 3.0.0
======================= ===============

Limitations
-----------

* The plugin is **only** compatible with OpenStack environments deployed with
  **Neutron + GRE** as network configuration in the environment configuration
  options. However, VXLAN can be configured on the plugin settings after
  the environment creation.

* The plugin works with Ubuntu 14.XX environment.

.. _v2015.06: https://github.com/midonet/midonet/tree/stable/v2015.06.2
.. _(MEM): http://docs.midokura.com/docs/latest/manager-guide/content/index.html
.. _provided: http://www.midokura.com/mem-eval
