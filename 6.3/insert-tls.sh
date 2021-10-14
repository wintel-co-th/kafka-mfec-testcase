#! /bin/sh

cat file02 | kafka_2.12-2.8.0/bin/kafka-console-producer.sh --broker-list kafka-ingress:9092 --producer.config client-ssl-auth.properties  --topic topic-a $1
