#!/bin/bash

# Update server.properties when executing
# env var will set when executing docker run
if [ ! -z "$ADVERTISED_HOST" ]; then
    sed -r -i "s/#(advertised.host.name)=(.*)/\1=$ADVERTISED_HOST/g" config/server.properties
fi

if [ ! -z "$ADVERTISED_PORT" ]; then
    sed -r -i "s/#(advertised.port)=(.*)/\1=$ADVERTISED_PORT/g" config/server.properties
fi

if [ ! -z "${NUM_PARTITIONS}" ]; then
    sed -r -i "s/(num.partitions)=(.*)/\1=${NUM_PARTITIONS}/g" config/server.properties
fi
echo "" >> config/server.properties
echo "auto.create.topics.enable=true" >> config/server.properties
#echo "advertised.host.name=$ADVERTISED_HOST" >> config/server.properties
#echo "advertised.port=$ADVERTISED_PORT" >> config/server.properties
echo "listeners=OUTSIDE://:9094,INSIDE://:9092" >>config/server.properties
echo "advertised.listeners=OUTSIDE://kafka:9094,INSIDE://$ADVERTISED_HOST:$ADVERTISED_PORT" >>config/server.properties
echo "listener.security.protocol.map=INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT" >>config/server.properties
echo "inter.broker.listener.name=INSIDE" >> config/server.properties
export KAFKA_PORT="$ADVERTISED_PORT"
export KAFKA_HOME="./"
export KAFKA_ZOOKEEPER_CONNECT="localhost:2181"
# Start to run zookeeper as background process
bin/zookeeper-server-start.sh config/zookeeper.properties &
bash /usr/local/bin/createTopics.sh &
# Start kafka server
bin/kafka-server-start.sh config/server.properties
