Installation Guide
------------------

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


### Create the MidoNet roles ###

MidoNet needs two roles besides the provided with Fuel: The NSDB role,
which will install the No State DataBase services (ZooKeeper and Cassandra) and
the Gateway one, that will provide the HA Gateway machine for inbound and
outbound traffic of the OpenStack deployment. (See [User Guide] for more info
about networking in MidoNet)

#### NSDB ####

Create a YAML file with the `nsdb` definition, like this:


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

#### Gateway ####

Create the role for MidoNet gateway by creating a file called `gateway.yaml`
with the following contents:

        name: midonet-gw
        meta:
          name: MidoNet HA Gateway
          description: MidoNet Gateway
        volumes_roles_mapping:
          - allocate_size: min
            id: os

And create the role for both environments (`Ubuntu 2014.2.2-6.1` and  `Centos
2014.2.2-6.1`) using the Fuel CLI[4]:

        $ fuel role --create --rel 1 --file gateway.yaml
        $ fuel role --create --rel 2 --file gateway.yaml


### Edit the Fuel deployment graph dependency cycle ###

Create a group type for Fuel 6.1 in a yaml file called `midonet_groups.yaml` with
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


Download the deployment tasks for the release 1:

        fuel rel --rel 1 --deployment-tasks --download

A file `./release_1/deployment_tasks.yaml` will be downloaded

Append the `midonet_groups.yaml` file into the `deployment_tasks.yaml` one

        cat /tmp/midonet_groups.yaml >> ./release_1/deployment_tasks.yaml

And upload the edited `deployment-tasks` file to the release 1:

        fuel rel --rel 1 --deployment-tasks --upload

Do the same for **release 2**:

        fuel rel --rel 2 --deployment-tasks --download
        cat /tmp/midonet_groups.yaml >> ./release_2/deployment_tasks.yaml
        fuel rel --rel 2 --deployment-tasks --upload

Even though current plugins for 6.1 version only allow to add tasks on
_pre\_deployment_ and _post_deployment_ stages, adding this group and these
tasks into the main graph will allow `nsdb` and `gateway` roles to:

 * Configure _logging_ to see Puppet and MCollective logs related to the tasks
   from the Fuel Web UI.
 * Access to hiera variables.
 * Access to global variables.
 * Configure the IP addresses for each Fuel network.

[1]: [Enable Experimental Features](https://docs.mirantis.com/openstack/fuel/fuel-6.1/operations.html#enable-experimental-features)
[2]: [Fuel Plugin Installation guidelines](https://docs.mirantis.com/openstack/fuel/fuel-6.1/user-guide.html#install-plugin)
[3]: [Task Based Deployment](https://docs.mirantis.com/openstack/fuel/fuel-6.1/reference-architecture.html#task-based-deployment)
[4]: [Fuel CLI](https://docs.mirantis.com/openstack/fuel/fuel-6.1/user-guide.html#using-fuel-cli)
[5]: [Creating a separate role and attaching a task to it](https://docs.mirantis.com/openstack/fuel/fuel-6.1/reference-architecture.html#creating-a-separate-role-and-attaching-a-task-to-it)
