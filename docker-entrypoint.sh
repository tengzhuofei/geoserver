#!/bin/bash
set -e

echo "ls /usr/share/geoserver/data_dir/"

ls /usr/share/geoserver/data_dir

ls /tmp

mkdir -p /usr/share/geoserver/data_dir/cluster/ && cp /tmp/*.properties /usr/share/geoserver/data_dir/cluster/

echo "ls /usr/share/geoserver/data_dir/cluster/"
ls /usr/share/geoserver/data_dir/cluster/

# set env
sed -i "s|^instanceName=.*|instanceName=${instanceName}|g" /usr/share/geoserver/data_dir/cluster/cluster.properties
sed -i "s|^toggleMaster=.*|toggleMaster=${toggleMaster}|g" /usr/share/geoserver/data_dir/cluster/cluster.properties

#brokerURL=tcp\://gsbroker\:61666
sed -i "s|^brokerURL=.*|brokerURL=tcp\://${brokerServiceName}\:61666|g" /usr/share/geoserver/data_dir/cluster/cluster.properties

sed -ie '/activemq.transportConnectors.server.uri/d' /usr/share/geoserver/data_dir/cluster/embedded-broker.properties

echo "activemq.transportConnectors.server.uri=tcp://${brokerServiceName}:61666?maximumConnections=1000&wireFormat.maxFrameSize=104857600&jms.useAsyncSend=true" >> /usr/share/geoserver/data_dir/cluster/embedded-broker.properties


if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

if [ "$1" = 'geoserver' ]; then
    id
    whoami
    exec /usr/share/geoserver/bin/startup.sh
    
    tail -f /dev/null
fi

exec "$@"