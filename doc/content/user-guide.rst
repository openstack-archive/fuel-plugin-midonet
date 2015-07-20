MidoNet Fuel Plugin User Guide
==============================

This document will guide you through the steps of install, configure and use the
MidoNet plugin for Fuel.

MidoNet version that will be deployed is v2015.03 and this plugin currently is
only compatible with version 6.1 of Mirantis OpenStack Fuel.

Terms
-----

Description
-----------

MidoNet is an Apache licensed production grade network virtualization software
for Infrastructure-as-a-Service (IaaS) clouds. This plugin provides the puppet
manifests to install all the components to deploy easily MidoNet with Fuel in a
production environment.

There are no prerequisites to use the MidoNet plugin: MidoNet is Open Source,
and the plugins sets the repositories from where download and install MidoNet
packages. Only on Fuel, you need to [#Enable Experimental Features](enable the
experimental features).

### Limitations ###

The plugin is **only** compatible with OpenStack environments deployed with
Neutron + GRE as network configuration.

Installation
------------

### Enable Experimental Features ###

To be able to install MidoNet, you should enable Experimental Features[1]. To do
so, Manually modify the /etc/fuel/version.yaml file to add "experimental" to the
"feature_groups" list in the "VERSION" section. For example:

        VERSION:
        ...
        feature_groups:
            - mirantis
            - experimental

And restart the Nailgun container with dependencies by running:

        $ dockerctl restart nailgun
        $ dockerctl restart nginx
        $ dockerctl shell cobbler
        $ cobbler sync
        $ exit


### Install the Plugin ###


To install the MidoNet Fuel plugin: 

  * Download it from the [Fuel Plugins Catalog](https://www.mirantis.com/products/openstack-drivers-and-plugins/fuel-plugins/) 

  * Copy the `rpm` file to the Fuel Master node:
        [root@home ~]# scp midonet-1.0-2.0.0-1.noarch.rpm root@fuel-master:/tmp

  * Log into Fuel master node and install the plugin using the Fuel CLI:
        [root@fuel-master ~]# fuel plugins --install midonet-1.0-2.0.0-1.noarch.rpm

  * Verify the plugin is installed correctly:
        [root@fuel-master ~]# fuel plugins
        id | name    | version | package_version
        ---|---------|---------|----------------
        9  | midonet | 2.0.0   | 2.0.0          


After that, you'll need to create a role and a group to put the tasks on the
Deployment Graph[3]. Read the next section to do so.

### Create the MidoNet roles ###

Create a YAML file with the _NoStateDataBase_ (nsdb) definition, like this:


        name: nsdb
        meta:
          name: No State Database for Midonet
          description: MidoNet Synchronization Services
        volumes_roles_mapping:
          - allocate_size: min
            id: os

And name it, for instance, `nsdb.yaml`

And create the role for both environments (`Ubuntu 2014.2.2-6.1` and  `Centos
2014.2.2-6.1`) using the Fuel CLI[4]:

        $ fuel role --create --rel 1 --file nsdb.yaml
        $ fuel role --create --rel 2 --file nsdb.yaml

TODO(devvesa): explain the `gateway` node.

Then you can create the groups `nsdb` and `gateway` on the tasks. This is based
on the *Creating a separate role and attaching a task to it[5]*  section on the
Reference Architecture. This is not necessary at all, but it is useful to set
the group after the *logging* task and see the Puppet logs when the deployment
of MidoNet tasks is deploying.

### Edit the Fuel deployment graph dependency cycle ###

Create a group type for Fuel 6.1 in a yaml file called `nsdb_group.yaml` with
the following content:


        - id: nsdb
          parameters:
            strategy:
              type: parallel
          requires:
          - deploy_start
          required_for:
          - deploy_end
          role:
          - nsdb
          type: group
          tasks:
          - logging
          - hiera
          - globals
          - netconfig


Download the deployment tasks for the release 1:

        fuel rel --rel 1 --deployment-tasks --download

A file `./release_1/deployment_tasks.yaml` will be downloaded

Append the `nsdb_group.yaml` file into the `deployment_tasks.yaml` one

        cat /tmp/nsdb_group.yaml >> ./release_1/deployment_tasks.yaml

And upload the edited `deployment-tasks` file to the release 1:

        fuel rel --rel 1 --deployment-tasks --upload

Do the same for **release 2**

Even though current plugins for 6.1 version only allow to add tasks on
_pre\_deployment_ and _post_deployment_ stages, adding this group and these
tasks into the main graph will allow `nsdb` to:

 * Configure _logging_ to see Puppet and MCollective logs related to the tasks
   from the Fuel Web UI.
 * Access to hiera variables.
 * Access to global variables.
 * Configure the IP addresses for each Fuel network.

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
