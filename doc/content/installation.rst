
.. raw:: pdf

   PageBreak oneColumn


Installation Guide
==================

Install the Plugin
------------------

To install the MidoNet Fuel plugin:

#. Download MidoNet plugin version |PluginVer| from `Fuel Plugins Catalog`_

#. Log into Fuel Master node and install the plugin using the
   `Fuel CLI <https://docs.mirantis.com/openstack/fuel/fuel-7.0/user-guide.html#using-fuel-cli>`_:

   ::

    # fuel plugins --install midonet-fuel-plugin-3.0-3.0.1-1.noarch.rpm

#. Verify that the plugin is installed correctly:
   ::

    # fuel plugins
    id | name    | version | package_version
    ---|---------|---------|----------------
    9  | midonet | 3.0.1   | 3.0.0


Enable Experimental Features
----------------------------

To be able to use MidoNet Fuel plugin correctly, Fuel `Experimental Features`_
must be enabled. This is done automatically by plugin post-install script,
assuming the plugin is installed on top of clean Fuel master installation.
In case the process has to be done manually, follow these steps:

#. Modify the ``/etc/fuel/version.yaml`` file in *Fuel Master*
   host to add ``experimental`` to the ``feature_groups`` list in the ``VERSION``
   section, just below ``mirantis`` item:

   ::

      VERSION:
      ...
      feature_groups:
        - mirantis
        - experimental

#. Restart the *Nailgun* container with dependencies by running::

   # dockerctl restart nailgun
   # dockerctl restart nginx
   # dockerctl shell cobbler
   # cobbler sync
   # exit

#. Make sure the *nginx* and the *nailgun* docker services finished the restart
   process before go on with the new section::

   # dockerctl check


Create the MidoNet roles
------------------------

MidoNet core functionality depends on two roles that are not provided by Fuel
on default:

- the **NSDB** role, which deploys the Network State DataBase services, namely
  ZooKeeper and Cassandra.

- the **Gateway** role, which provides the MidoNet gateway service needed for
  handling external *OpenStack* traffic. (See `MidoNet Fuel Plugin User Guide`_ for
  more info about networking in MidoNet)

The above roles are added automatically by plugin post-install script,
assuming the plugin is installed on top of clean Fuel master installation.
In case the process has to be done manually, follow these steps:

NSDB role
`````````

#. Create a YAML file with the **NSDB** role definition, like this:

   ::

    name: nsdb
    meta:
      name: Network State Database for MidoNet
      description: MidoNet Synchronization Services
    volumes_roles_mapping:
      - allocate_size: min
        id: os

#. Name it, for instance, ``nsdb.yaml``. Push the role for the environment
   (``Ubuntu 2015.1.0-7.0``) using the
   `Fuel CLI <https://docs.mirantis.com/openstack/fuel/fuel-7.0/user-guide.html#using-fuel-cli>`_:

   ::

    $ fuel release
    ---|----------------------|-------------|------------------|-------------
    2  | Kilo on Ubuntu 14.04 | available   | Ubuntu           | 2015.1.0-7.0
    1  | Kilo on CentOS 6.5   | unavailable | CentOS           | 2015.1.0-7.0

   ::

    $ fuel role --create --release 2 --file nsdb.yaml


Gateway role
````````````

#. Create the role for **MidoNet Gateway** by creating a file called
   ``gateway.yaml`` with the following contents:

   ::

      name: midonet-gw
      meta:
      name: MidoNet HA Gateway
       description: MidoNet Gateway
      volumes_roles_mapping:
        - allocate_size: min
          id: os

#. Create the role for the environment (``Ubuntu 2015.1.0-7.0``) using the
   `Fuel CLI <https://docs.mirantis.com/openstack/fuel/fuel-7.0/user-guide.html#using-fuel-cli>`_:

   ::

    $ fuel release
    ---|----------------------|-------------|------------------|-------------
    2  | Kilo on Ubuntu 14.04 | available   | Ubuntu           | 2015.1.0-7.0
    1  | Kilo on CentOS 6.5   | unavailable | CentOS           | 2015.1.0-7.0

   ::

    $ fuel role --create --release 2 --file gateway.yaml


Edit the Fuel deployment graph dependency cycle
-----------------------------------------------

The roles that were just added needs to be accompanied with appropriate
deployment tasks, so that `Fuel's Deployment Graph
<https://docs.fuel-infra.org/fuel-dev/develop/modular-architecture.html#granular-deployment-process>`_
is fully populated. Again, needed deployment tasks are added automatically by
plugin post-install script, assuming the plugin is installed on top of clean
Fuel master installation. In case the process still has to be done manually,
follow these steps:

#. Create a group type for Fuel |FuelVer| in a YAML file called
   ``/tmp/midonet_groups.yaml`` with the following content::

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
    - id: midonet-gw
      parameters:
        strategy:
          type: parallel
      required_for:
      - deploy_end
      requires:
      - deploy_start
      role:
      - midonet-gw
      tasks:
      - logging
      - hiera
      - globals
      - netconfig
      type: group


#. Download the deployment tasks for the **release 2** (``Ubuntu 2015.1.0-7.0``):

   ::

    $ fuel release
    ---|----------------------|-------------|------------------|-------------
    2  | Kilo on Ubuntu 14.04 | available   | Ubuntu           | 2015.1.0-7.0
    1  | Kilo on CentOS 6.5   | unavailable | CentOS           | 2015.1.0-7.0

   ::

      fuel rel --rel 2 --deployment-tasks --download

#. A file ``./release_2/deployment_tasks.yaml`` will be downloaded.

#. Without moving from your current directory, append the
   ``/tmp/midonet_groups.yaml`` file into the ``deployment_tasks.yaml``:

   ::

      cat /tmp/midonet_groups.yaml >> ./release_2/deployment_tasks.yaml

#. Upload the edited ``deployment-tasks`` file to the ``release 2``:

   ::

     fuel rel --rel 2 --deployment-tasks --upload


#. Current Fuel Plugins framework only allows to apply tasks on
   *pre_deployment* and *post_deployment* stages, adding these groups
   and tasks into the main graph will allow **NSDB** and **Gateway**
   associated tasks to:

   - Configure *logging* to see Puppet and MCollective logs related to the tasks
     from the Fuel Web UI.

   - Access to hiera variables.

   - Access to global variables.

   - Configure the IP addresses for
     `each Fuel network type <https://docs.mirantis.com/openstack/fuel/fuel-7.0/reference-architecture.html#network-architecture>`_.

.. _Experimental Features: https://docs.mirantis.com/openstack/fuel/fuel-7.0/operations.html#enable-experimental-features
.. _Fuel Plugins Catalog: https://www.mirantis.com/products/openstack-drivers-and-plugins/fuel-plugins/

