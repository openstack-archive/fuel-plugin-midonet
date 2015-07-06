#!/bin/bash

puppet module uninstall stdlib
puppet module install midonet-midonet
puppet module install --force midonet-neutron
