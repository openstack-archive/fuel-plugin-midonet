MidoNet Fuel Plugin User Guide
==============================

This document will guide you through the steps of install, configure and use the
MidoNet plugin for Fuel.

MidoNet is an Apache licensed production grade network virtualization software
for Infrastructure-as-a-Service (IaaS) clouds. This plugin provides the puppet
manifests to install all the components to deploy easily MidoNet with Fuel in a
production environment.

MidoNet version that will be deployed is v2015.06 and this plugin currently is
only compatible with version 6.1 of Mirantis OpenStack Fuel.

There are no prerequisites to use the MidoNet plugin: MidoNet is Open Source,
and the plugins sets the repositories from where download and install MidoNet
packages. Only on Fuel, you need to [#Enable Experimental Features](enable the
experimental features).

### Limitations ###

The plugin is **only** compatible with OpenStack environments deployed with
Neutron + GRE as network configuration.

Terms
-----

Description
-----------




After that, you'll need to create a role and a group to put the tasks on the
Deployment Graph[3]. Read the next section to do so.


Then you can create the groups `nsdb` and `gateway` on the tasks. This is based
on the *Creating a separate role and attaching a task to it[5]*  section on the
Reference Architecture. This is not necessary at all, but it is useful to set
the group after the *logging* task and see the Puppet logs when the deployment
of MidoNet tasks is deploying.

Guide
-----

### Select Environment ###

When creating the environment, choose Neutron with GRE on the Network tab.

TODO(devvesa): add screenshot

MidoNet plugin does not interact with the rest of the options, so choose
whatever your deployment demands on them.

### Enable Plugin ###

You should enter Settings tab of the Fuel Web UI to do that. Please, provide
more details here. Specially, in terms of fields/checkboxes etc

Once the environment is created, enter in Settings tab of the Fuel Web UI,
scroll down until 'Neutron MidoNet plugin' and enable the checkbox.

After that, choose which encapsulation technology you want
to use to send data between hosts on the Private network: GRE or VXLAN and one
of the available MidoNet versions.

TODO(devvesa); add screenshot

### Network Configuration ###

TODO(devvesa): study which Network configuration fits better with MidoNet,
according to Neutron Neutron topologies
(https://docs.mirantis.com/openstack/fuel/fuel-6.1/reference-architecture.html#neutron-network-topologies)
and document it here.

Appendix
--------

[1]: [Enable Experimental Features](https://docs.mirantis.com/openstack/fuel/fuel-6.1/operations.html#enable-experimental-features)
[2]: [Fuel Plugin Installation guidelines](https://docs.mirantis.com/openstack/fuel/fuel-6.1/user-guide.html#install-plugin)
[3]: [Task Based Deployment](https://docs.mirantis.com/openstack/fuel/fuel-6.1/reference-architecture.html#task-based-deployment)
[4]: [Fuel CLI](https://docs.mirantis.com/openstack/fuel/fuel-6.1/user-guide.html#using-fuel-cli)
[5]: [Creating a separate role and attaching a task to it](https://docs.mirantis.com/openstack/fuel/fuel-6.1/reference-architecture.html#creating-a-separate-role-and-attaching-a-task-to-it)
