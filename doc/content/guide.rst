
.. raw:: pdf

   PageBreak oneColumn


MidoNet Fuel Plugin User Guide
==============================

Once the Fuel MidoNet plugin has been installed (following
`Installation Guide`_), you can create *OpenStack* environments that use
MidoNet SDN controller as a Neutron back-end.

MidoNet Networks
----------------

MidoNet changes the behavior of default Neutron deployments, understanding
what MidoNet plugin does, especially in regard to external networks, is
essential to configure and use MidoNet Fuel plugin properly.

MidoNet plugin is compatible with both **Neutron + GRE** and
**Neutron + VxLAN** network tunneling overlays, so let's focus on showing
the differences beteewn the Neutron default ML2 deployments first.

Neutron without MidoNet plugin
``````````````````````````````

Fuel |FuelVer| reference architecture contains some useful informaition in
`Neutron Network Topologies
<https://docs.mirantis.com/openstack/fuel/fuel-7.0/reference-architecture.html#neutron-with-gre-segmentation-and-ovs>`_
section. First, let's have an overview of Neutron-default ML2 topolgy:

.. image:: images/fuelml2gre.png
   :width: 100%

In this topology, red, or "North" network represents the Public Internet,
including Floating IP subnet assigned to OpenStack cloud. That means API access
to services and Virtual Machines' Floating IPs share the same L2/L3 network.
This topology overloads the Controllers' traffic, since Neutron L3 agent
service is running on the controller, answers all ARP requests coming from
"North" traffic that belong to Virtual Machines' Floating IPs, does NAT on all
of the traffic destined to Floating IP assigned to Virtual Machines and places
the resulting packets in the overlay of the green, "South" network (br-tun).

Even in an HA deployment, the L3 agent only runs on one of the Controllers, and
only gets spawned in another host if the previous one loses connectivity
(active-standby Corosync / Pacemaker HA setup).

Node hosting Neutron Controller has to:

- Serve the API requests coming from users
- Run the data and RPC messaging services (Rabbitmq and MySQL is running on the
  controllers as well)
- Handle all the North-South traffic that comes to and from the Virtual Machines.


Neutron with MidoNet plugin
```````````````````````````

With MidoNet, Neutron separates the control traffic from the data traffic. 
Even the Floating IPs live in the network overlay. Floating IP subnet is
separated from the services API network range (called Public Network on Fuel
and represented by the red network below) and MidoNet gateway advertises the
routes that belong to Floating Ranges to BGP peers. So MidoNet plugin forces
you to define a new Network on its settings, and allocation-range from
environment settings get overridden.

MidoNet deployment topology:

.. image:: images/midonet_fuel.png
   :width: 100%

On this topology diagram:

- **External Public & API networks** is the red one on the diagram. Only
  *Controllers* (access to OpenStack APIs and Horizon) and *Gateway* need
  access to this network. On the external side of this underlay we expect
  an ISP BGP router(s), ready to learn our OpenStack Floating IP subnet
  route so it can pass traffic to our virtual machines.

- **Private network** underlay is the green one on the diagram. All the traffic
  between virtual machines is tunneled by MidoNet on top of this network.
  Including traffic to and form floating IP addresses.

- **Management network** is the blue one. All nodes need to be connected to
  it, this network is used for access to *NSDB* nodes in order to access 
  virtual networks topology and flow information.

- **PXE/Admin network** is the gray one. Needed by Fuel master to orchestrate
  the deployment.

- **Storage network** is not shown on the diagram, as it is out of scope of
  this guide (and NEutron & MidoNet itself).

MidoNet gateway is native distributed system, one can place as many gateways
necessary, so North-South traffic can be distributed and balanced. Once BGP
sessions are established and routes are exchanged between BGP "peers", 
each North-to-South network packet gets routed from the External Public API
network to one of the MidoNet gateways. It does not matter which of them gets
the packet, they work as if they are a single entity. MidoNet gateway sends
the inbound packet directly to the Compute that hosts the target virtual
machine.

In this way controller nodes gets significantly less overloaded, since they
only need to answer user requests and they don't handle VM traffic at all
(the only exception is the metadata traffic at VM provisioning time).

Following the learned concepts, we are ready to create a Fuel environment
that uses MidoNet.


Select Environment
------------------

#. When creating the environment in the Fuel UI wizard, choose **Neutron with
   tunneling segmentation** (second option) on the Network tab.

   .. image:: images/tunneling.png
      :width: 100%

   After that, you will be able to choose between *GRE* or *VXLAN* segmentation.
   MidoNet works with both.

#. MidoNet plugin does not interact with the rest of the options, so choose
   whatever your deployment demands on them. Follow instructions from
   `the official Mirantis OpenStack documentation <https://docs.mirantis.com/openstack/fuel/fuel-7.0/user-guide.html#create-a-new-openstack-environment>`_
   to finish the configuration.

Alternatively, this can be done in fuel cli:

::

   $ fuel env --create --name test-deployment --rel 2 --net neutron --nst tun


Once the environment is created, open the *Settings* tab of the Fuel Web UI.


Install Midokura Enterprise MidoNet (Optional)
----------------------------------------------

#. Installing Midokura Enterprise MidoNet, you will be able to use some specific
   features from MidoNet only available on the Enterprise version.

#. Activate the option **Install Midokura Enterprise MidoNet**.

   .. image:: images/mem.png
      :width: 100%

#. Select the Midokura Enterprise MidoNet (MEM) version and fill the **Username** and
   **Password** fields for downloading the packages from the repository.

   .. image:: images/mem_credentials.png
      :width: 100%


Configure MidoNet Plugin
------------------------

#. Configuring the MidoNet plugin for Fuel, you will override most of the options
   of the *Public Network* section of the *Settings* tab of the environment:

   .. image:: images/overridden_options.png
      :width: 100%

   Fuel will still reserve IP addresses of the *IP range* (first row) to assign
   API-accessible IPs to the OpenStack services, but the rest will be overridden by
   the plugin options that you are about to configure, making the Floating Network
   full-overlay and pure floating.

#. Activate the option **Assign public networks to all nodes**.
   By default, Fuel only gives public access to Controllers. We need to enable
   this option in order to have external connectivity to Gateway nodes.

   .. image:: images/public_to_all.png
     :width: 100%

#. Select the plugin checkbox and fill the options:

   .. image:: images/plugin_config.png
      :width: 100%

   Let's explain them:

   - **Tunnel Type**: Here you can choose between GRE or VxLAN as
     tunneling technology. Both are supported by MidoNet, but VxLAN is
     recommended for its performance.

   - **Floating Network subnet** Public Network CIDR**: This option represents
     the CIDR of Neutron's external network (overriding Public Network CIDR for
     the default Neutron ML2 plugin). This subnet **MUST NOT** be the same as
     the *Public Network* CIDR section of the *Settings* tab of the
     environment. Since there is no option to fine-tune this kind of network
     separation control within Fuel core, one must use MidoNet Fuel plugin
     settings to do it.

   - **Floating Network Gateway IP**: The Gateway IP address to the MidoNet
     Virtual IP subnet. This IP address is usually set to the first available
     IP in the subnet. Make sure that the address really belongs to the
     *Floating Network subnet* CIDR.

   - **Floating Network Range Start** and **Floating Network Range End**:
     First and last IP address of the Floating range of IPs available for use
     on virtual machines.

   - **BGP routing subnet**: IP subnet in which BGP peers resides. Both local
     and remote BGP peer IP addresses must belong to this subnet.


   - **BGP local IP address** and **BGP local AS**: This pair of parameters
     identifies BGP peer local to MidoNet gateway. They are usually given by
     ISP to be set into your networking equipment (in this case your MidoNet
     gateway) by the network administrators. "AS number" stands for Autonomous
     System Number.

   - **BGP peer IP address** and **BGP peer AS**: This pair of parameters
     usually identifies BGP peer on the side of your ISP. They are usually
     given by ISP to be set into your BGP peer so that those peers know where
     to find each other.


Assign Roles to Nodes
---------------------

#. Go to the *Nodes* tab and you will see the **Network State DataBase** and
   **MidoNet HA Gateway** roles available to be assigned to roles.

   .. image:: images/nodes_to_roles.png
      :width: 100%

#. Some general advice to be followed:

   - **Gateway** role should be given to a dedicated node.

   - **NSDB** role can be combined with any other roles, but note that it needs
     at least 4GB RAM for itself (dedicated storage hihgly recommended).


Finish environment configuration
--------------------------------

#. Run `network verification check <https://docs.mirantis.com/openstack/fuel/fuel-7.0/user-guide.html#verify-networks>`_

#. Press `Deploy button <https://docs.mirantis.com/openstack/fuel/fuel-7.0/user-guide.html#deploy-changes>`_ to once you are done with environment configuration.


Operations and Troubleshooting
------------------------------

A successful deployment done with MidoNet Fuel plugin will produce fully
working OpenStack environment, with MidoNet Neutron network back-end.
MidoNet is fully compatible with Neutron and Nova APIs and most of its
aspects can be directly managed by OpenStack Horizon WEB interface, as well
as Neutron API.

Operating MidoNet
`````````````````

For advanced networking features supported by MidoNet please
see `MidoNet Operations Guide`_. For general MidoNet troubleshooting, assuming
the deployment went fine, please see `MidoNet Troubleshooting Guide`_.

.. _MidoNet Operations Guide: https://docs.midonet.org/docs/v2015.06/en/operations-guide/content/index.html
.. _MidoNet Troubleshooting Guide: https://docs.midonet.org/docs/v2015.06/en/troubleshooting-guide/content/index.html


Troubleshooting MidoNet Fuel deployment
```````````````````````````````````````

In a case MidoNet Fuel deployment failed for some reason, first thing to
do is to make sure that the initiated deployment satisfies the plugin
`Known Limitations`_.

In a case MidoNet Fuel deployment failed for some other reason, useful thing
to be checked are various log outputs available in Fuel WEB UI. Click on the
**Logs** tab and observe logging information. Default log displayed in the
WEB interface shows "Web backend" logs, which are too general to provide
any troubleshooting information, we want to check "Astute" logs, which can be
selected by clicking *Source* drop down menu, followed by clicking **Show**
button. In case of deployment errors, important messages will be shown in red,
identifying which stage of deployment may have failed, and on which node(s).

Next step is to look into how deployment tasks were executed at target nodes.
After identifying nodes in previous step, select "Other servers" in the
**Logs** drop-down menu, following by selecting an appropriate node in
**Node** and "puppet" in **Source** drop-down menus. Again, important failures
should be marked in red. Depending on user's level of understanding of these
messages, they should either be included in MidoNet support claims to help
to help the troubleshooting or an action can be taken by user to prevent issue
from happening on re-deployment.


Note on Fuel upgrades
`````````````````````

Fuel provides special mechanism for upgrading locally hosted (usually on a Fuel
master node itself) Operating System as well as OpenStack repositories. This is
achieved with executing following commands on Fuel master node (assuming
environment number 1 deployed on nodes 2, 3, 4, 5 and 6):

   ::

    # fuel-createmirror -M
    # fuel --env 1 node --node-id 2 3 4 5 6 --tasks upload_core_repos

For deployments based on MidoNet this will cause Neutron services to be restarted.
This is an expected behavior, and it will not affect network functionality on VMs,
virtual routers or gateways.

