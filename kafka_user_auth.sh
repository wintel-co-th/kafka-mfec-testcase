#! /bin/sh

#kafka_nemspaces=kafka
#kafka_bootstrap=kafka-bootstrap.thdlcd3-uat.aiaazure.biz
#my_user=chaiyapon
#my_cluster=thdlcd3-uat-kafka-cluster

$(rm -rf  6.3/client-ssl-auth.properties)
$(rm -rf  6.3/*)
$(ls -lrth  6.3/)

kubectl get secret my_user -o jsonpath='{.data.user\.crt}' -n kafka_nemspaces | base64 --decode > 6.3/user.crt
kubectl get secret my_user -o jsonpath='{.data.user\.key}' -n kafka_nemspaces | base64 --decode > 6.3/user.key
kubectl get secret my_user -o jsonpath='{.data.user\.p12}' -n kafka_nemspaces | base64 --decode > 6.3/user.p12
kubectl get secret my_user -o jsonpath='{.data.user\.password}' -n kafka_nemspaces | base64 --decode > 6.3/user.password


echo "==============Import the entry in user.p12 into another keystore=============="

export USER_P12_FILE_PATH=6.3/user.p12
export USER_KEY_PASSWORD_FILE_PATH=6.3/user.password
export KEYSTORE_NAME=6.3/kafka-auth-keystore.jks
export KEYSTORE_PASSWORD=foobar
export PASSWORD=$(cat 6.3/user.password)

echo this is $PASSWORD
echo this is $USER_KEY_PASSWORD_FILE_PATH
keytool -importkeystore -deststorepass $KEYSTORE_PASSWORD -destkeystore $KEYSTORE_NAME -srckeystore $USER_P12_FILE_PATH -srcstorepass $PASSWORD -srcstoretype PKCS12 -noprompt

echo "==============Extract the cluster CA certificate and password================="

kubectl get secret my_cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}'   -n kafka_nemspaces | base64 --decode > 6.3/ca.crt
kubectl get secret my_cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}'   -n kafka_nemspaces | base64 --decode > 6.3/ca.password

echo "==============Import it into truststore======================================="

export CERT_FILE_PATH=6.3/ca.crt
export CERT_PASSWORD_FILE_PATH=6.3/ca.password
export KEYSTORE_LOCATION=6.3/cacerts
export PASSWORD=$(cat 6.3/ca.password)
export TRUSTSTORE_PASSWORD=changeit

echo this is $PASSWORD

keytool -importcert -alias strimzi-kafka-cert -file $CERT_FILE_PATH -keystore $KEYSTORE_LOCATION -keypass $PASSWORD -deststorepass $TRUSTSTORE_PASSWORD -noprompt

echo "============== Create properties file for Kafka CLI clients===================="
$(ls -lrth  6.3/)
touch  6.3/client-ssl-auth.properties
echo "bootstrap.servers=kafka_bootstrap:443" >> 6.3/client-ssl-auth.properties
echo "security.protocol=SSL" >> 6.3/client-ssl-auth.properties
echo "ssl.truststore.location=6.3/cacerts" >> 6.3/client-ssl-auth.properties
echo "ssl.truststore.password=changeit" >> 6.3/client-ssl-auth.properties
echo "ssl.keystore.location=6.3/kafka-auth-keystore.jks" >> 6.3/client-ssl-auth.properties
echo "ssl.keystore.password=foobar" >> 6.3/client-ssl-auth.properties
echo "ssl.key.password=$(cat 6.3/user.password)" >> 6.3/client-ssl-auth.properties

echo " $(cat 6.3/client-ssl-auth.properties)"

echo "===============Load data to topic================================================="

$(cat file02 | kafka_2.12-2.8.0/bin/kafka-console-producer.sh --broker-list kafka_bootstrap:443 --producer.config 6.3/client-ssl-auth.properties  --topic topic-b $1 )


echo "================comsumer data from topic==========================================" 

kafka_2.12-2.8.0/bin/kafka-console-consumer.sh --bootstrap-server kafka_bootstrap:443  --topic topic-b --consumer.config 6.3/client-ssl-auth.properties --from-beginning --timeout-ms 10000
