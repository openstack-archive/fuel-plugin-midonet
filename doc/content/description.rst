MidoNet Plugin for Fuel 6.1
===========================

MidoNet is an Apache licensed production grade network virtualization software
for Infrastructure-as-a-Service (IaaS) clouds. This plugin provides the puppet
manifests to install all the components to deploy easily MidoNet with Fuel in a
production environment.

MidoNet version that will be deployed is v2015.06_ and this plugin currently is
only compatible with version 6.1 of Mirantis OpenStack Fuel.

There are no prerequisites to use the MidoNet plugin: MidoNet is Open Source,
and the plugins sets the repositories from where download and install MidoNet
packages.


Requirements
------------

======================= ===============
Requirement             Version/Comment
======================= ===============
Fuel                    6.1
MidoNet plugin for Fuel 2.0.0
======================= ===============

Limitations
-----------

The plugin is **only** compatible with OpenStack environments deployed with
**Neutron + GRE** as network configuration in the environment configuration
options. However, VXLAN can be configured on the plugin settings after
the environment creation.

The plugin currently only work with CentOS 6.5 environments. We are working on
make it work for Ubuntu environments

.. _v2015.06: https://github.com/midonet/midonet/tree/stable/v2015.06.2
