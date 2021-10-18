#! /bin/sh

kubectl get secret my-user -o jsonpath='{.data.user\.crt}' -n my-namespaces | base64 --decode > 6.3/user.crt
kubectl get secret my-user -o jsonpath='{.data.user\.key}' -n my-namespaces | base64 --decode > 6.3/user.key
kubectl get secret my-user -o jsonpath='{.data.user\.p12}' -n my-namespaces | base64 --decode > 6.3/user.p12
kubectl get secret my-user -o jsonpath='{.data.user\.password}' -n my-namespaces | base64 --decode > 6.3/user.password


## Import the entry in user.p12 into another keystore

export USER_P12_FILE_PATH=6.3/user.p12
export USER_KEY_PASSWORD_FILE_PATH=6.3/user.password
export KEYSTORE_NAME=kafka-auth-keystore.jks
export KEYSTORE_PASSWORD=foobar
export PASSWORD=$(cat 6.3/user.password)

cd 6.3/ && keytool -importkeystore -deststorepass $KEYSTORE_PASSWORD -destkeystore $KEYSTORE_NAME -srckeystore $USER_P12_FILE_PATH -srcstorepass $PASSWORD -srcstoretype PKCS12

##Extract the cluster CA certificate and password

kubectl get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.crt}'   -n my-namespaces | base64 --decode > 6.3/ca.crt
kubectl get secret my-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}'   -n my-namespaces | base64 --decode > 6.3/ca.password

##Import it into truststore

export CERT_FILE_PATH=6.3/ca.crt
export CERT_PASSWORD_FILE_PATH=6.3/ca.password
export KEYSTORE_LOCATION=6.3/cacerts
export PASSWORD=$(cat 6.3/ca.password)

cd 6.3/ && keytool -importcert -alias strimzi-kafka-cert -file $CERT_FILE_PATH -keystore $KEYSTORE_LOCATION -keypass $PASSWORD -noprompt

##// Create properties file for Kafka CLI clients
touch  6.3/client-ssl-auth.properties
echo "bootstrap.servers=my-cluster" >> 6.3/client-ssl-auth.properties
echo "security.protocol=SSL" >> 6.3/client-ssl-auth.properties
echo "ssl.truststore.location=6.3/cacerts" >> 6.3/client-ssl-auth.properties
echo "ssl.truststore.password=changeit" >> 6.3/client-ssl-auth.properties
echo "ssl.keystore.location=6.3/kafka-auth-keystore.jks" >> 6.3/client-ssl-auth.properties
echo "ssl.keystore.password=foobar" >> 6.3/client-ssl-auth.properties
echo "ssl.key.password=$(cat 6.3/ca.password)" >> 6.3/client-ssl-auth.properties


## // Load data to topic

cat file02 | kafka_2.12-2.8.0/bin/kafka-console-producer.sh --broker-list kafka-ingress:9092 --producer.config client-ssl-auth.properties  --topic topic-a $1



