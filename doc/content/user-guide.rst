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

Installation
------------

TODO: Enable experimental features

Follow the Fuel Plugin Installation guidelines[1] to install the MidoNet plugin.

After that, you'll need to create a role and a group to put the tasks on the
Deployment Graph[2]

### Create the role NSDB ###

Create a YAML file with the role definition, like this:


        name: nsdb
        meta:
          name: No State Database for Midonet
          description: MidoNet Synchronization Services
        volumes_roles_mapping:
          - allocate_size: min
            id: os

And name it, for instance, `nsdb.yaml`

And create the role for both environments (`Ubuntu 2014.2.2-6.1` and  `Centos
2014.2.2-6.1`) using the Fuel CLI:

        $ fuel role --create --rel 1 --file nsdb.yaml
        $ fuel role --create --rel 2 --file nsdb.yaml

Then you can create the group 'nsdb` on the tasks. This is based on the
*Creating a separate role and attaching a task to it[3]*  section on the
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

Open your favourite text editor and edit the
'./release_1/deployment_tasks.yaml', look for the `primary-controller` id group:

        - id: primary-controller
          parameters:
          strategy:
          type: one_by_one
          required_for:
          - deploy_end
          requires:
          - deploy_start
          role:
          - primary-controller
          type: group

And replace the `requires` tag from `deploy_start` to `nsdb`:

        - id: primary-controller
          parameters:
          strategy:
          type: one_by_one
          required_for:
          - deploy_end
          requires:
          - nsdb
          role:
          - primary-controller
          type: group

Q: WHAT I HAVE DONE?
A: MidoNet API will be deployed in the controller. To configure the API, we need
to know the location of the ZooKeeper services. Replacing `deploy_start` to
`nsdb` (the role that deploys Zookeeper) we will guarantee that any controller
will always be deployed after any `nsdb` host and the API will have all the
needed data to be deployed properly.

And upload the edited `deployment-tasks` file to the release 1:

        fuel rel --rel 1 --deployment-tasks --upload

Do the same for **release 2**

Even though current plugins for 6.1 version only allow to add tasks on
_pre\_deployment_ and _post_deployment_ stages, adding this group and these
tasks into the main graph will allow `nsdb` to:

 * Configure _logging_ to see Puppet and MCollective logs related to the tasks
   from the Fuel Web Console.
 * Access to hiera variables.
 * Access to global variables.
 * Configure the IP addresses for each Fuel network.

Guide
-----

### Select Environment ###

TODO(devvesa): still not sure if we can use the Neutron + GRE one

### Enable Plugin ###

Once the environment is created, choose which encapsulation technology you want
to use to send data between hosts on the Private network: GRE or VXLAN.

TODO(devvesa): add screenshot

### Network Configuration ###

TODO(devvesa): study which Network configuration fits better with MidoNet,
according to Neutron Neutron topologies
(https://docs.mirantis.com/openstack/fuel/fuel-6.1/reference-architecture.html#neutron-network-topologies)
and document it here.

Appendix
--------

[1]: [Fuel Plugin Installation guidelines](https://docs.mirantis.com/openstack/fuel/fuel-6.1/user-guide.html#install-plugin)
[2]: [Task Based Deployment](https://docs.mirantis.com/openstack/fuel/fuel-6.1/reference-architecture.html#task-based-deployment)
[3]: [Creating a separate role and attaching a task to
it](https://docs.mirantis.com/openstack/fuel/fuel-6.1/reference-architecture.html#creating-a-separate-role-and-attaching-a-task-to-it)
