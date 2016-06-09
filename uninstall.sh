#!/bin/bash
#
# Fuel 7.0 default deployment config unhack script
#

KEYSTONE_PASS=$(sed -n '/"FUEL_ACCESS"/,/^"/s/\(^[ ]*"password": "\)\(.*\)\("\)/\2/p')
[ -z "$KEYSTONE_PASS" ] && KEYSTONE_PASS=$(sed -n '/FUEL_ACCESS/,/^[ ]/s/\(^[ ]*password: \)\(.*\)\(\)/\2/p')
[ -z "$KEYSTONE_PASS" ] && KEYSTONE_PASS=admin
export KEYSTONE_USER=admin
export KEYSTONE_PASS
FUEL_VER=$(fuel --version 2>&1 | tail -n1 | cut -c 1-3)
YAML_CFG=/etc/fuel/$FUEL_VER/version.yaml

# Unregister additional roles
echo "Un-registering MidoNet NSDB & GW Fuel roles:"
REL=$(fuel rel 2>/dev/null | grep "on Ubuntu" | awk '{ print $1 }')
fuel role --release $REL --role nsdb --delete &> /dev/null
fuel role --release $REL --role midonet-gw --delete &> /dev/null

# Disable Fuel experimental features
if grep -q "\- experimental" $YAML_CFG; then
  echo "Disabling Fuel experimental features in $YAML_CFG"
  sed -i '/- experimental/d' $YAML_CFG
  dockerctl restart nailgun &> /dev/null
  echo -n "Restarting Nailgun"
  while ! fuel plugins &> /dev/null; do
    echo -n .
    sleep 1
  done
  echo
fi

