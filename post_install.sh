#!/bin/bash
#
# Fuel 7.0 default deployment config hack script
#

KEYSTONE_PASS=$(sed -n '/"FUEL_ACCESS"/,/^"/s/\(^[ ]*"password": "\)\(.*\)\("\)/\2/p')
[ -z "$KEYSTONE_PASS" ] && KEYSTONE_PASS=$(sed -n '/FUEL_ACCESS/,/^[ ]/s/\(^[ ]*password: \)\(.*\)\(\)/\2/p')
[ -z "$KEYSTONE_PASS" ] && KEYSTONE_PASS=admin
export KEYSTONE_USER=admin
export KEYSTONE_PASS
FUEL_VER=$(fuel --version 2>&1 | tail -n1 | cut -c 1-3)
YAML_CFG=/etc/fuel/$FUEL_VER/version.yaml

# Enable Fuel experimental features
if ! grep -q "\- experimental" $YAML_CFG; then
  echo "Enableing Fuel experimental features in $YAML_CFG"
  sed -i 's|^\([ ]*\)- mirantis|\0\n\1- experimental|' $YAML_CFG
  dockerctl restart nailgun > /dev/null
  echo -n "Restarting Nailgun"
  while ! fuel plugins &> /dev/null; do
    echo -n .
    sleep 1
  done
  echo
#  dockerctl restart nginx
#  dockerctl shell cobbler
#  cobbler sync
fi

# Generate and register additional roles
echo "Updating MidoNet NSDB & GW Fuel roles:"
cat > /tmp/role-nsdb.yaml << THEEND
name: nsdb
meta:
  name: Network State Database for MidoNet
  description: MidoNet Synchronization Services
volumes_roles_mapping:
  - allocate_size: min
    id: os
THEEND
cat > /tmp/role-gw.yaml << THEEND
name: midonet-gw
meta:
  name: MidoNet HA Gateway
  description: MidoNet Gateway
volumes_roles_mapping:
- allocate_size: min
  id: os
THEEND
REL=$(fuel rel 2>/dev/null | grep "on Ubuntu" | awk '{ print $1 }')
fuel role --update --rel $REL --file /tmp/role-nsdb.yaml 2> /dev/null
fuel role --update --rel $REL --file /tmp/role-gw.yaml 2> /dev/null
rm -rf /tmp/role-nsdb.yaml /tmp/role-gw.yaml

# Check if additional deployment tasks needs to be enabled
pushd /tmp > /dev/null
fuel rel --rel $REL --deployment-tasks --download 2> /dev/null
if ! grep -q "\- id: nsdb" release_$REL/deployment_tasks.yaml; then
  echo "Enabling MidoNet NSDB Fuel deployment tasks"
  cat >> release_$REL/deployment_tasks.yaml << THEEND
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
THEEND
  fuel rel --rel $REL --deployment-tasks --upload 2> /dev/null
fi
if ! grep -q "\- id: midonet-gw" release_$REL/deployment_tasks.yaml; then
  echo "Enabling MidoNet GW Fuel deployment tasks"
  cat >> release_$REL/deployment_tasks.yaml << THEEND
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
THEEND
  fuel rel --rel $REL --deployment-tasks --upload 2> /dev/null
fi
rm -rf /tmp/release_$REL/deployment_tasks.yaml
popd > /dev/null

echo Done.
echo

