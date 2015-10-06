
Installation Guide
==================

Enable Experimental Features
----------------------------

#. To be able to install **MidoNet**, you should enable `Experimental Features`_.
   To do so, manually modify the ``/etc/fuel/version.yaml`` file in *Fuel Master*
   host to add ``experimental`` to the ``feature_groups`` list in the ``VERSION``
   section, just below ``mirantis`` item:

   ::

      VERSION:
      ...
      feature_groups:
        - mirantis
        - experimental

#. Restart the *Nailgun* container with dependencies by running::

   $ dockerctl restart nailgun
   $ dockerctl restart nginx
   $ dockerctl shell cobbler
   $ cobbler sync
   $ exit


Install the Plugin
------------------

To install the MidoNet Fuel plugin:

#. Download it from the `Fuel Plugins Catalog`_
#. Copy the *rpm* file to the Fuel Master node:
   ::

      [root@home ~]# scp midonet-1.0-2.0.0-1.noarch.rpm root@fuel-master:/tmp

#. Log into Fuel Master node and install the plugin using the
   `Fuel CLI <https://docs.mirantis.com/openstack/fuel/fuel-6.1/user-guide.html#using-fuel-cli>`_:

   ::

      [root@fuel-master ~]# fuel plugins --install midonet-1.0-2.0.0-1.noarch.rpm

#. Verify that the plugin is installed correctly:
   ::

     [root@fuel-master ~]# fuel plugins
     id | name    | version | package_version
     ---|---------|---------|----------------
     9  | midonet | 2.0.0   | 2.0.0


Create the MidoNet roles
------------------------

MidoNet needs two roles besides the ones provided with Fuel:

- the **NSDB** role, which will install the Network State DataBase services
  (ZooKeeper and Cassandra).

- the **Gateway** role, that will provide the HA Gateway machine for inbound and
  outbound traffic of the *OpenStack* deployment. (See `User Guide
  <./guide.rst>`_ for more info about networking in MidoNet)


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

#. Name it, for instance, ``nsdb.yaml``. Push the role for both environments
   (``Ubuntu 2014.2.2-6.1`` and ``Centos 2014.2.2-6.1``) using the
   `Fuel CLI <https://docs.mirantis.com/openstack/fuel/fuel-6.1/user-guide.html#using-fuel-cli>`_:

   ::

     $ fuel role --create --rel 1 --file nsdb.yaml
     $ fuel role --create --rel 2 --file nsdb.yaml


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

#. Create the role for both environments
   (`Ubuntu 2014.2.2-6.1` and  `Centos 2014.2.2-6.1`) using the
   `Fuel CLI <https://docs.mirantis.com/openstack/fuel/fuel-6.1/user-guide.html#using-fuel-cli>`_

    ::

      $ fuel role --create --rel 1 --file gateway.yaml
      $ fuel role --create --rel 2 --file gateway.yaml


Edit the Fuel deployment graph dependency cycle
-----------------------------------------------

Now, you'll need to create a group inside
`Fuel's Deployment Graph <https://docs.fuel-infra.org/fuel-dev/develop/modular-architecture.html#granular-deployment-process>`_
to put the
tasks related to the recently created roles on the Fuel Deployment Graph.

#. Create a group type for Fuel 6.1 in a YAML file called
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


#. Download the deployment tasks for the release 1:

   ::

      fuel rel --rel 1 --deployment-tasks --download

#. A file ``./release_1/deployment_tasks.yaml`` will be downloaded.

#. Without moving from your current directory, append the
   ``/tmp/midonet_groups.yaml`` file into the ``deployment_tasks.yaml``:

   ::

      cat /tmp/midonet_groups.yaml >> ./release_1/deployment_tasks.yaml

#. Upload the edited ``deployment-tasks`` file to the release 1:

   ::

     fuel rel --rel 1 --deployment-tasks --upload

#. Do the same for **release 2**:

   ::

     fuel rel --rel 2 --deployment-tasks --download
     cat /tmp/midonet_groups.yaml >> ./release_2/deployment_tasks.yaml
     fuel rel --rel 2 --deployment-tasks --upload

#. Though current Fuel Plugins Framework only allows to apply tasks on
   *pre_deployment* and *post_deployment* stages for 6.1 Fuel release,
   adding these groups and these tasks into the main graph will allow **NSDB**
   and **Gateway** associated tasks to:

   - Configure *logging* to see Puppet and MCollective logs related to the tasks
     from the Fuel Web UI.

   - Access to hiera variables.

   - Access to global variables.

   - Configure the IP addresses for
     `each Fuel network type <https://docs.mirantis.com/openstack/fuel/fuel-6.1/reference-architecture.html#network-architecture>`_.

.. _Experimental Features: https://docs.mirantis.com/openstack/fuel/fuel-6.1/operations.html#enable-experimental-features
.. _Fuel Plugins Catalog: https://www.mirantis.com/products/openstack-drivers-and-plugins/fuel-plugins/
