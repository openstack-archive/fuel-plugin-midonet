Fuel Plugin for MidoNet
=======================

MidoNet is an Apache licensed production grade network virtualization
software for Infrastructure-as-a-Service (IaaS) clouds. This plugin
provides the puppet manifests to install all the components to easily
deploy MidoNet with Fuel in a production environment.

MidoNet open source version that will be deployed is v2015.06.
Midokura Enterprise Midonet (MEM) version that will be deployed is
1.9.

This plugin currently is only compatible with version 7.0 of Mirantis
OpenStack Fuel.

Problem description
===================
Currently, Fuel has no support to install OpenStack environments that
use MidoNet SDN controller as a Neutron backend plugin. This Fuel
plugin provides support to automatically install MidoNet.


Proposed change
---------------
This plugin will provide the needed Puppet manifests to easily
configure and deploy MidoNet as a Neutron backend plugin.


Define the custom node roles for MidoNet components
===================================================
MidoNet needs two roles besides the ones already provided by Fuel.

* NSDB role: which will install the Network State DataBase services.
  These are the componentes deployed: Cassandra NoSQL database, Zookeeper.
* Midonet-gw role.

What is new from the previous versions
======================================

This plugin was originally developed for Fuel 6.1, and there are some
important changes included in this plugin version for Fuel 7.0:

- Regarding encapsulation methods, the plugin only supported GRE on
  previous versions. Now it supports both GRE and VxLAN.

- Regarding OS support, the plugin supported both CentOS 6.5 and
  Ubuntu 14.04 on previous versions. Now it only supports Ubuntu
  14.04, since Fuel 7.0 itself only supports this OS version.

Alternatives
------------

N/A - the aim is to implement a Fuel plugin.

Data model impact
-----------------

None, although a new Release will be installed into the existing model.

REST API impact
---------------

None.

Upgrade impact
--------------

This plugin is only compatible with Fuel 7.0. If an upgrade is performed
on the Fuel Master node to Fuel version higher than 7.0, it could stop
working.

Security impact
---------------

None.

Other end user impact
---------------------

Once the plugin is installed, a new tab dedicated to MidoNet will
be created in the Fuel web UI. The user can select the Midokura
Enterprise MidoNet version to install, and also configure the credentials
in the same tab.

Performance Impact
------------------

None.

Plugin impact
-------------

The plugin will:

* Install MidoNet v2015.06 and Midokura Enterprise MidoNet (MEM) 1.9
  (if selected in the Fuel web UI)


Other deployer impact
---------------------

The plugin requires all the nodes to have public network assigned IP's

Implementation
==============

Assignee(s)
-----------

Primary assignee:

- Jaume Devesa <jaume@midokura.com> (developer)
- Carmela Rubinos <carmela@midokura.com> (developer)

Quality Assurance:
- Lucas Eznarriaga <lucas@midokura.com>

Work Items
----------

Dependencies
============

* Fuel 7.0

Testing
=======

* Prepare a test plan.

* Test the plugin according to the test plan.

Documentation Impact
====================

* Create the following documentation:

 * User Guide.

 * Test Plan.

 * Test Report.

References
==========

- `MidoNet v2015.06 Documentation <http://docs.midonet.org/>`_
- `Midokura Enterprise MidoNet (MEM) v1.9 Documentation <http://docs.midokura.com/docs/latest/manager-guide/content/index.html>`_
- `Midokura Enterprise MidoNet (MEM) 30 Day Trial <http://www.midokura.com/mem-eval/>`_

