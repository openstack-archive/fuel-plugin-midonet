MidoNet Fuel Plugin User Guide
==============================

Once the Fuel MidoNet plugin has been installed (following `Installation Guide`_), you can
create *OpenStack* environments that use MidoNet SDN controller as a Neutron
Backend.

MidoNet Networks
----------------

MidoNet changes the behaviour of Neutron
deployments and understanding what MidoNet plugin does (especially on Public
Network Ranges) is essential to configure the Fuel plugin properly.

MidoNet plugin is compatible with **Neutron + GRE** environment, so let's focus
on the deployment with ML2 first, to introduce the differences that MidoNet
plugin has.

Without MidoNet plugin
``````````````````````

Fuel 6.1 reference architecture has a schema with the `networks that deploys
<https://docs.mirantis.com/openstack/fuel/fuel-6.1/reference-architecture.html#neutron-with-gre-segmentation-and-ovs>`_.

ML2 networks:

.. image:: images/fuelml2gre.png
   :width: 100%

In this schema, red network represents the Public + Floating IP range. That
means API access to services and Virtual Machines' Floating IPs share the same
L2/L3 network. This schema overloads the Controllers' traffic, since Neutron L3
service is running on the controller, answers ARP requests coming from inbound
traffic that belong to Virtual Machines' Floating IPs, NATs the Floating IP to
the private IP address of the Virtual Machine and puts the packet in the overlay
of the green network (br-tun).

Even in an HA deployment, the L3 agent only runs in one of the Controller, and
only gets spawned in another host if the previous one loses connectivity (log
into a controller and see how Pacemaker is configured).

So Controller has to:

- Serve the API requests coming from users
- Run the data and messaging services (rabbitmq and mysql is running on the
  controllers as well)
- Handle all the N/S traffic that comes to and from the Virtual Machines.

With MidoNet plugin, separate the control traffic from the data one is easier.

With MidoNet plugin
```````````````````

In MidoNet, even the Floating IPs live in the overlay. Floating Range is
separated from the services API network range (called Public Network on Fuel
and represented by the red network below) and MidoNet gateway advertises the
routes that belong to Floating Ranges to BGP peers. So MidoNet plugin forces
you to define a new Network on its settings, and allocation-range from
environment settings get overridden.

MidoNet deployment schema:

.. image:: images/midonet_fuel.png
   :width: 100%

On this schema:

- **Public API network** is the red one. Only *Controllers* and *Gateway* need
  to access to it. It should be a BGP router listening on the network to learn the
  Floating Range of the Virtual Machines.

- **Private network** is the green one. All the traffic between virtual
  machines is tunneled by MidoNet over this network. Even Floating IP addresses.

- **Management network** is the blue one. All the nodes need to be connected to
  it, this network is used by *NSDB* nodes to get information about Virtual
  Network infrastructure and Virtual Machines' network flows.

- **PXE/Admin network** is the grey one. Needed by Fuel master to orchestrate
  the deployment.

- **Storage network** is not represented, since MidoNet nodes are not involved
  on it.

MidoNet gateway is pure-distributed and you can put as many gateways as you
want, so you don't overload machines in N/S traffic. Once BGP sessions are
established and routes are exchanged (gateway has a quagga instance running on
it), N/S traffic comes routed from the Public API network to one of the MidoNet
Gateways. It does not matter which of them gets the packet, they work as if it
were a single machine. MidoNet Gateway sends the inbound packet directly to the
host that has the Virtual Machine that has to receive the traffic.

Controller nodes get less overloaded, since they only need to answer user
requests and they almost don't handle VM traffic (only the metadata requests at
VM creation).

Now we are ready to create a Fuel environment that uses MidoNet.


Select Environment
------------------

#. When creating the environment in the Fuel UI wizard, choose Neutron with GRE on the Network tab.

   .. image:: images/gre_environment.png
      :width: 100%

#. MidoNet plugin does not interact with the rest of the options, so choose
   whatever your deployment demands on them. Follow instructions from
   `the official Mirantis OpenStack documentation <https://docs.mirantis.com/openstack/fuel/fuel-6.1/user-guide.html#create-a-new-openstack-environment>`_
   to finish the configuration.

#. Once the environment is created, open the *Settings* tab of the Fuel Web UI.

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
   this option in order to have external connectivity to Gateway Nodes.

   .. image:: images/public_to_all.png
     :width: 100%

#. Select the plugin checkbox and fill the options:

   .. image:: images/plugin_config.png
      :width: 100%

   Let's explain them:

   - **Tunnel Type**: Even you have chosen GRE tunnels on environment creation,
     this is a convention because the deployment that Fuel does by default is the
     closest to the MidoNet plugin one. Here you can choose between GRE or VXLAN as
     tunneling technology.

   - **Public Network CIDR**: This option will be the CIDR of Neutron's External
     Network. This range **MUST NOT** be the same as the *Public Network* section
     of the *Settings* tab of the environment. There is no way to control this from
     the plugin development, so this restriction is all up to you!

   - **Public Gateway IP**: The IP address of the *Public Network CIDR*. It will be
     the Gateway IP address of the MidoNet Virtual network. This IP address can not
     be in the next section's range. . Recommendation: put the first IP address of
     the CIDR. There is no way to control that this IP belongs to the CIDR in from
     the plugin development, so be aware on the value you are setting.

   - **Floating Range Start** and **Floating Range End**: First and last IP address
     of the Floating range of IPs available to be used on Virtual Machines.

   - **Local AS** Your Autonomous System number to establish a BGP connection.

   - **BGP Peer X AS** and **BGP X IP Address**: Information needed to establish a
     BGP connection to remote peers.

Install Midokura Enterprise MidoNet
-----------------------------------

#. Installing Midokura Enterprise MidoNet, you will be able to use some specific
   features from MidoNet only available on the Enterprise version, like the MidoNet
   Manager (GUI).

#. Activate the option **Install Midokura Enterprise MidoNet**.

   .. image:: images/mem.png
      :width: 100%

#. Select the Midokura Enterprise MidoNet (MEM) version and fill the **Username** and
   **Password** fields for downloading the packges from the repository.

   .. image:: images/mem_credentials.png
      :width: 100%

Assign Roles to Nodes
---------------------

#. Go to the *Nodes* tab and you will see the **Network State DataBase** and
   **MidoNet HA Gateway** roles available to be assigned to roles.

   .. image:: images/nodes_to_roles.png
      :width: 100%

#. Just follow one rule:

   - **DO NOT** assign the role **Gateway** and the role **Controller** altogether.

   - **NSDB** role can be combined with any other role.

Finish environment configuration
--------------------------------

#. Run `network verification check <https://docs.mirantis.com/openstack/fuel/fuel-6.1/user-guide.html#verify-networks>`_

#. Press `Deploy button <https://docs.mirantis.com/openstack/fuel/fuel-6.1/user-guide.html#deploy-changes>`_ to once you are done with environment configuration.
