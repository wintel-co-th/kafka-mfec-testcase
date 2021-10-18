#! /bin/sh

kafka_nemspaces=kafka
kafka_bootstrap=kafka-bootstrap.thdlcd03-uat.aiaazure.biz
my_user=chaiyapon
my_cluster=thdlcd3-uat-kafka-cluster



##Extract the cluster CA certificate and password

kubectl get secret $my_cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}'   -n $kafka_nemspaces | base64 --decode > 6.3/ca.crt

keytool -import -trustcacerts -alias root -file 6.3/ca.crt -keystore 6.3/truststore.jks -storepass abc123 -noprompt

## // Load data to topic

cat file02 | kafka_2.12-2.8.0/bin/kafka-console-producer.sh --broker-list $kafka_bootstrap:443 --producer-property security.protocol=SSL --producer-property ssl.truststore.password=abc123 --producer-property ssl.truststore.location=6.3/truststore.jks --topic topic-a $1



## // comsumer data from topic 

kafka_2.12-2.8.0/bin/kafka-console-consumer.sh --bootstrap-server $kafka_bootstrap:443  --topic topic-a --consumer-property security.protocol=SSL --consumer-property ssl.truststore.password=abc123
 --consumer-property ssl.truststore.location=6.3/truststore.jks  --from-beginning --timeout-ms 10000
