.. raw:: pdf

   PageBreak oneColumn

.. _bgp_peer:

Appendix C - Setting up test BGP peer
=====================================

`BGP`_ routing is an exterior gateway protocol supported and recommended to
MidoNet production use case. An external BGP peer is necessary for Floating IP
(FIP) traffic between the deployed OpenStack cloud instances and the external
network(s). These BGP peers are usually available for production or data-center
ISP environments, so for the sake of supporting BGP tests under lab or
proof-of-concept conditions we are providing instructions on how to set up a
"fake" BGP peer that provide fully functional external connectivity. This guide
shows how it can be done by setting up VyOS network operating system instance
to serve up as an external BGP peer.

`VyOS`_ is a community fork of `Vyatta`_, a Linux-based network operating
system that provides software-based network routing, firewall, and VPN
functionality.

.. _BGP: https://en.wikipedia.org/wiki/Border_Gateway_Protocol
.. _VyOS: http://vyos.net
.. _Vyatta: https://en.wikipedia.org/wiki/Vyatta


Introduction
------------

VyOS works just fine as a live OS when booted from `VyOS ISO`_ and configured
properly, but we will cover some basic steps on how to install it to an actual
server or a virtual machine. Being a network operating system and a router
appliance, it makes sense to install it on a host that has multiple network
interfaces. Minimum hardware requirements for VyOS are single core CPU and
512MB of RAM. It can run just fine without any permanent storage, which is
only necessary to save the configuration state.

.. _VyOS ISO:  <http://mirror.vyos.net/iso/release/1.1.7/vyos-1.1.7-amd64.iso


Required addressing information
-------------------------------

For the sake of this example we assume following IP addresses will be used
in this guide:

- VyOS management IP on eth0 interface: **10.20.0.254/24**
- Default gateway for management subnet: **10.20.0.1**


Also, BGP protocol itself needs some parameters to be set up. For our simple
demonstration we assume that VyOS BGP peer that we are creating is going to
communicate with MidoNet gateway BGP peer. As a part of BGP specification, each
BGP peer has to have AS number which identifies it when connecting to other
peers. Also, BGP peers needs to find each other on specific IP addresses,
belonging to a same IP subnet. For our example, we assume following AS numbers
and IP addresses:

- BGP IP subnet: **10.88.88.0/30**
- VyOS BGP peer IP address: **10.88.88.1**
- VyOS BGP peer AS number: **65535**
- MidoNet BGP gateway IP address: **10.88.88.2**
- MidoNet BGP gateway AS number: **12345**


Finally, to fulfill the purpose of this BGP setup, we need to know which
Floating IP subnet is going to be handled by MidoNet-based OpenStack cloud,
so we specify subnet:

- Floating IP subnet: **200.200.200.0/24**



VyOS Installation
-----------------

We start installing by booting our server or VM from `VyOS ISO`_ and logging
in with username and password, both **vyos** by default. Following that,
we run this command to install VyOS to a hard drive:

::

   vyos@vyos:~$ install image

After that the following installation prompts will be displayed:

::

   Welcome to the VyOS install program.  This script
   will walk you through the process of installing the
   VyOS image to a local hard drive.
   Would you like to continue? (Yes/No) [Yes]: Yes
   Probing drives: OK
   Looking for pre-existing RAID groups...none found.
   The VyOS image will require a minimum 1000MB root.
   Would you like me to try to partition a drive automatically
   or would you rather partition it manually with parted?  If
   you have already setup your partitions, you may skip this step

   Partition (Auto/Parted/Skip) [Auto]: 

   I found the following drives on your system:
    vda	4294MB

   Install the image on? [vda]:

   This will destroy all data on /dev/vda.
   Continue? (Yes/No) [No]:

Confirm the that you really want to install VyOS to the target disk drive by
typing **Yes**. The rest of the installation can be completed by simply
pressing Enter on each prompt, and typing the desired administrator password when
asked:

::

   How big of a root partition should I create? (1000MB - 4294MB) [4294]MB: 

   Creating filesystem on /dev/vda1: OK
   Done!
   Mounting /dev/vda1...
   What would you like to name this image? [1.1.7]: 
   OK.  This image will be named: 1.1.7
   Copying squashfs image...
   Copying kernel and initrd images...
   Done!
   I found the following configuration files:
       /config/config.boot
       /opt/vyatta/etc/config.boot.default
   Which one should I copy to vda? [/config/config.boot]: 

   Copying /config/config.boot to vda.
   Enter password for administrator account
   Enter password for user 'vyos':
   Retype password for user 'vyos':
   I need to install the GRUB boot loader.
   I found the following drives on your system:
    vda	4294MB

   Which drive should GRUB modify the boot partition on? [vda]:

   Setting up grub: OK
   Done!
   vyos@vyos:~$

This means that the installation has been successful, time to reboot
VyOS and do some configuration:

::

   vyos@vyos:~$ reboot
   Proceed with reboot? (Yes/No) [No] Yes

   Broadcast message from root@vyos (ttyS0) (Mon Feb 29 12:28:15 2016):

   The system is going down for reboot NOW!


Essential VyOS Configuration
----------------------------

Following the reboot, we need to configure VyOS management IP address and ssh
access. Do this by accessing **configuration** mode:

::

   vyos@vyos:~$ configure
   [edit]

Set up management IP address, default gateway, ssh access and a DNS name:

::

   vyos@vyos# set interfaces ethernet eth0 address 10.20.0.254/24
   [edit]
   vyos@vyos# set interfaces ethernet eth0 description MGMT
   [edit]
   vyos@vyos# set protocols static route 0.0.0.0/0 next-hop 10.20.0.1
   [edit]
   vyos@vyos# set service ssh port 22
   [edit]
   vyos@vyos# set service dns forwarding listen-on eth0
   [edit]
   vyos@vyos# set service dns forwarding name-server 8.8.8.8
   [edit]

To apply as well as save the configuration changes do:

::

   vyos@vyos# commit
   [ service ssh ]
   Restarting OpenBSD Secure Shell server: sshd.

   [edit]
   vyos@vyos# save
   Saving configuration to '/config/config.boot'...
   Done
   [edit]
   vyos@vyos# exit
   exit
   vyos@vyos:~$ exit
   logout

Our VyOS instance should be accessible via ssh at 10.20.0.254 now:

::

   $ ssh vyos@10.20.0.254


VyOS BGP Configuration
----------------------

It is time to configure VyOS as a BGP peer. For this we will use all the
IP and AS addresses we mentioned above. Enter the configuration mode,

::

   vyos@vyos:~$ configure
   [edit]

followed by a stream of commands:

::

   set interfaces ethernet eth1 address 10.88.88.1/30
   set policy prefix-list DEFAULT rule 100 action permit
   set policy prefix-list DEFAULT rule 100 prefix 0.0.0.0/0
   set policy prefix-list DEFAULT rule 999 action deny
   set policy prefix-list DEFAULT rule 999 le 32
   set policy prefix-list DEFAULT rule 999 prefix 0.0.0.0/0
   set policy prefix-list fromAS12345 rule 100 action permit
   set policy prefix-list fromAS12345 rule 100 le 32
   set policy prefix-list fromAS12345 rule 100 prefix 200.200.200.0/24
   set policy prefix-list fromAS12345 rule 999 action deny
   set policy prefix-list fromAS12345 rule 999 le 32
   set policy prefix-list fromAS12345 rule 999 prefix 0.0.0.0/0
   commit

   set policy route-map fromAS12345 rule 100 match ip address prefix-list fromAS12345
   set policy route-map fromAS12345 rule 100 action permit
   set policy route-map fromAS12345 rule 999 action deny
   commit

   set policy route-map toAS12345 rule 100 action permit
   set policy route-map toAS12345 rule 100 match ip address prefix-list DEFAULT
   set policy route-map toAS12345 rule 100 set metric 100
   set policy route-map toAS12345 rule 999 action deny
   commit

   set protocols bgp 65535 neighbor 10.88.88.2 default-originate route-map toAS12345
   set protocols bgp 65535 neighbor 10.88.88.2 route-map export toAS12345
   set protocols bgp 65535 neighbor 10.88.88.2 route-map import fromAS12345
   set protocols bgp 65535 neighbor 10.88.88.2 soft-reconfiguration inbound
   set protocols bgp 65535 neighbor 10.88.88.2 remote-as 12345
   commit

Now, we can verify if our VyOS BGP peer is actually connected to the other BGP peer(s):

::

   vyos@vyos# run show ip bgp summary 
   BGP router identifier 10.20.0.254, local AS number 65535
   IPv4 Unicast - max multipaths: ebgp 1 ibgp 1
   RIB entries 1, using 96 bytes of memory
   Peers 1, using 4560 bytes of memory

   Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
   10.88.88.2      4 12345       7       8        0    0    0 00:04:22        1

   Total number of neighbors 1

If you see an output similar to the above, congratulations, you have set up your
VyOS BGP peer correctly! It is advised to save this configuration:

::

   vyos@vyos# save
   Saving configuration to '/config/config.boot'...
   Done
   [edit]


VyOS NAT Configuration
----------------------

In our test setup, the Floating IP subnet 200.200.200.0/24 is not real
public IP subnet, hence the "fake BGP peer" mention in the begining of
this guide. In lab condition we want to make "fake" OpenStack instances
into believing they really can use a floating IP from a
200.200.200.0/24 subnet. For that to work we have to set up some
NAT rules in our VyOS so that our OpenStack instances can really talk to
public Internet.
First, we create this NAT rule to allow Floating IP subnet to access
public Internet:

::

   set nat source rule 10 source address 200.200.200.0/24
   set nat source rule 10 outbound-interface eth0
   set nat source rule 10 protocol all
   set nat source rule 10 translation address masquerade
   commit

Second, we create NAT rule that will allow traffic from out management
subnet, 10.20.0.0/24, to a fake public Floating IP subnet:

::

   set nat source rule 11 source address 10.20.0.0/24
   set nat source rule 11 outbound-interface eth1
   set nat source rule 11 protocol all
   set nat source rule 11 translation address masquerade
   commit

Don't forget to save this configuration:

::

   vyos@vyos# save
   Saving configuration to '/config/config.boot'...
   Done
   [edit]


Final consideration
-------------------

In a likely case that we want to make fake Floating IP subnet,
200.200.200.0/24, available from the rest of our internal management
network, 10.20.0.0/24, it is highly advised to set up a static route
in the management network gateway router, 10.20.0.1. For example:

::

   # ip route add 200.200.200.0/24 via 10.20.0.254

In case management gateway router is not accessible, the above
static route can be set at each individual host that needs to access
"fake" Floating IP network range.
