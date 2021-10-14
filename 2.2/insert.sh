#! /bin/sh

cat /home/kafka/file01 | /opt/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic topic-a $1
