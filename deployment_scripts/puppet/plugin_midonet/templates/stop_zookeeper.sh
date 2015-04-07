#!/bin/bash
/bin/ps -ef|/bin/grep java|/bin/grep zookeeper 
RETCODE=$?
if [ $RETCODE == 0 ]
then 
  /bin/kill `/bin/ps -ef |/bin/grep java|/bin/grep zookeeper|/bin/awk '{print \$2}'`
fi
rm -rf /var/lib/zookeper/data/version-2
rm /var/lib/zookeeper/data/zookeeper_server.pid

