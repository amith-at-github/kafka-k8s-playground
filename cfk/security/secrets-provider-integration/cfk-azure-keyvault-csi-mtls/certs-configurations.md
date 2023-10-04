# This documentaton discusses an easier approach for creating various certificates for Confluent platform and its components.

# For this demo we use cfssl to generate certicates from JSON configurations. This is a dependency
### In Actual deployment scenario, 
   -  you can use your PKI to create the necessary certificates 
   -  and then PKI generated certificates can be imported into kubernetes secrets.
   -  NOTE: IN this demo, all generated certificates are kept in a "/generated" folder and it is safe to delete the generated folder and can be recreated from JSon configurations

## To install cfssl
```
sudo apt-get update
sudo apt-get -y install golang-cfssl

cd <PATH-TO-PROJECT>/mrc-mtls-acls
export DEMO_HOME=$PWD
```



# CREATE CERT authority (Azure only support pk)

`mkdir $DEMO_HOME/certs/component-certs/generated && openssl genrsa -out $DEMO_HOME/certs/component-certs/generated/rootCAkey.key 2048`
## FOR AZURE PKCS8 is only supported ( RUN THIS COMMAND ONLY - NOT ABOVE COMMAND)
`mkdir $DEMO_HOME/certs/component-certs/generated && openssl genpkey -out $DEMO_HOME/certs/component-certs/generated/rootCAkey.key -algorithm RSA -pkeyopt rsa_keygen_bits:2048`

# Generate the CA Certificate

```
openssl  req -x509  -new -nodes  -days 3650 \
  -key $DEMO_HOME/certs/component-certs/generated/rootCAkey.key \
  -out $DEMO_HOME/certs/component-certs/generated/cacerts.pem \
  -subj "/C=US/ST=CA/L=Santaclara/O=AmithCorporation/OU=InfoSec/CN=AmithCA"

cat $DEMO_HOME/certs/component-certs/generated/cacerts.pem $DEMO_HOME/certs/component-certs/generated/rootCAkey.key > $DEMO_HOME/certs/component-certs/generated/cacerts-cert-pkcs8.pem

```

### check the validity of CA

`openssl x509 -in $DEMO_HOME/certs/component-certs/generated/cacerts.pem -text -noout`

#Create Confluent server certificates
### Not creating any certificate for zookeeper, becaues PROD setting is no SSL and Auth is Digest




# Create Kafka server certificates ( for AZ)


# Create Kafka server certificates
#### Use the SANs listed in kafka-server-domain.json

```
cfssl gencert -ca=$DEMO_HOME/certs/component-certs/generated/cacerts.pem \
-ca-key=$DEMO_HOME/certs/component-certs/generated/rootCAkey.key \
-config=$DEMO_HOME/certs/component-certs/ca-config.json \
-profile=server $DEMO_HOME/certs/component-certs/kafka-server-domain.json | cfssljson -bare $DEMO_HOME/certs/component-certs/generated/kafka-server

openssl pkcs8 \
-topk8 \
-inform PEM \
-outform PEM \
-in $DEMO_HOME/certs/component-certs/generated/kafka-server-key.pem \
-out $DEMO_HOME/certs/component-certs/generated/kafka-server-key-pkcs8.pem \
-nocrypt

cat $DEMO_HOME/certs/component-certs/generated/kafka-server.pem $DEMO_HOME/certs/component-certs/generated/kafka-server-key-pkcs8.pem > $DEMO_HOME/certs/component-certs/generated/kafka-server-cert-pkcs8.pem

```

# Create ControlCenter server certificates
#### Use the SANs listed in controlcenter-server-domain.json

```
cfssl gencert -ca=$DEMO_HOME/certs/component-certs/generated/cacerts.pem \
-ca-key=$DEMO_HOME/certs/component-certs/generated/rootCAkey.key \
-config=$DEMO_HOME/certs/component-certs/ca-config.json \
-profile=server $DEMO_HOME/certs/component-certs/controlcenter-server-domain.json | cfssljson -bare $DEMO_HOME/certs/component-certs/generated/controlcenter-server

openssl pkcs8 \
-topk8 \
-inform PEM \
-outform PEM \
-in $DEMO_HOME/certs/component-certs/generated/controlcenter-server-key.pem \
-out $DEMO_HOME/certs/component-certs/generated/controlcenter-server-key-pkcs8.pem \
-nocrypt

cat $DEMO_HOME/certs/component-certs/generated/controlcenter-server.pem $DEMO_HOME/certs/component-certs/generated/controlcenter-server-key-pkcs8.pem > $DEMO_HOME/certs/component-certs/generated/controlcenter-server-cert-pkcs8.pem

```

# Create SchemaRegistry server certificates
#### Use the SANs listed in schemaregistry-server-domain.json

```
cfssl gencert -ca=$DEMO_HOME/certs/component-certs/generated/cacerts.pem \
-ca-key=$DEMO_HOME/certs/component-certs/generated/rootCAkey.key \
-config=$DEMO_HOME/certs/component-certs/ca-config.json \
-profile=server $DEMO_HOME/certs/component-certs/schemaregistry-server-domain.json | cfssljson -bare $DEMO_HOME/certs/component-certs/generated/schemaregistry-server

openssl pkcs8 \
-topk8 \
-inform PEM \
-outform PEM \
-in $DEMO_HOME/certs/component-certs/generated/schemaregistry-server-key.pem \
-out $DEMO_HOME/certs/component-certs/generated/schemaregistry-server-key-pkcs8.pem \
-nocrypt

cat $DEMO_HOME/certs/component-certs/generated/schemaregistry-server.pem $DEMO_HOME/certs/component-certs/generated/schemaregistry-server-key-pkcs8.pem > $DEMO_HOME/certs/component-certs/generated/schemaregistry-server-cert-pkcs8.pem

```

# Create Connect server certificates
#### Use the SANs listed in connect-server-domain.json

```
cfssl gencert -ca=$DEMO_HOME/certs/component-certs/generated/cacerts.pem \
-ca-key=$DEMO_HOME/certs/component-certs/generated/rootCAkey.key \
-config=$DEMO_HOME/certs/component-certs/ca-config.json \
-profile=server $DEMO_HOME/certs/component-certs/connect-server-domain.json | cfssljson -bare $DEMO_HOME/certs/component-certs/generated/connect-server

openssl pkcs8 \
-topk8 \
-inform PEM \
-outform PEM \
-in $DEMO_HOME/certs/component-certs/generated/connect-server-key.pem \
-out $DEMO_HOME/certs/component-certs/generated/connect-server-key-pkcs8.pem \
-nocrypt

cat $DEMO_HOME/certs/component-certs/generated/connect-server.pem $DEMO_HOME/certs/component-certs/generated/connect-server-key-pkcs8.pem > $DEMO_HOME/certs/component-certs/generated/connect-server-cert-pkcs8.pem

```

# Create ksqlDB server certificates
#### Use the SANs listed in ksqldb-server-domain.json

```
cfssl gencert -ca=$DEMO_HOME/certs/component-certs/generated/cacerts.pem \
-ca-key=$DEMO_HOME/certs/component-certs/generated/rootCAkey.key \
-config=$DEMO_HOME/certs/component-certs/ca-config.json \
-profile=server $DEMO_HOME/certs/component-certs/ksqldb-server-domain.json | cfssljson -bare $DEMO_HOME/certs/component-certs/generated/ksqldb-server

openssl pkcs8 \
-topk8 \
-inform PEM \
-outform PEM \
-in $DEMO_HOME/certs/component-certs/generated/ksqldb-server-key.pem \
-out $DEMO_HOME/certs/component-certs/generated/ksqldb-server-key-pkcs8.pem \
-nocrypt

cat $DEMO_HOME/certs/component-certs/generated/ksqldb-server.pem $DEMO_HOME/certs/component-certs/generated/ksqldb-server-key-pkcs8.pem > $DEMO_HOME/certs/component-certs/generated/ksqldb-server-cert-pkcs8.pem


```


# check validity of server certificates

```
openssl x509 -in $DEMO_HOME/certs/component-certs/generated/kafka-server-full.pem -text -noout

openssl x509 -in $DEMO_HOME/certs/component-certs/generated/kafka-server.pem -text -noout

openssl x509 -in $DEMO_HOME/certs/component-certs/generated/controlcenter-server.pem -text -noout

openssl x509 -in $DEMO_HOME/certs/component-certs/generated/schemaregistry-server.pem -text -noout

openssl x509 -in $DEMO_HOME/certs/component-certs/generated/connect-server.pem -text -noout

openssl x509 -in $DEMO_HOME/certs/component-certs/generated/ksqldb-server.pem -text -noout
```
