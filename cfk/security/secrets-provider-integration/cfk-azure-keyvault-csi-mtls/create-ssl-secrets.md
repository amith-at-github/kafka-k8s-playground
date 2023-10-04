# In this step you will create secrets for each of confluent component TLS certificate (Kubernetes secret)


### For namespace confluent - kubernetes secret

```
kubectl create secret generic tls-kafka \
  --from-file=fullchain.pem=$DEMO_HOME/certs/component-certs/generated/kafka-server.pem \
  --from-file=cacerts.pem=$DEMO_HOME/certs/component-certs/generated/cacerts.pem \
  --from-file=privkey.pem=$DEMO_HOME/certs/component-certs/generated/kafka-server-key.pem \
  --namespace confluent

kubectl create secret generic tls-controlcenter \
  --from-file=fullchain.pem=$DEMO_HOME/certs/component-certs/generated/controlcenter-server.pem \
  --from-file=cacerts.pem=$DEMO_HOME/certs/component-certs/generated/cacerts.pem \
  --from-file=privkey.pem=$DEMO_HOME/certs/component-certs/generated/controlcenter-server-key.pem \
  --namespace confluent

kubectl create secret generic tls-schemaregistry \
  --from-file=fullchain.pem=$DEMO_HOME/certs/component-certs/generated/schemaregistry-server.pem \
  --from-file=cacerts.pem=$DEMO_HOME/certs/component-certs/generated/cacerts.pem \
  --from-file=privkey.pem=$DEMO_HOME/certs/component-certs/generated/schemaregistry-server-key.pem \
  --namespace confluent

kubectl create secret generic tls-connect \
  --from-file=fullchain.pem=$DEMO_HOME/certs/component-certs/generated/connect-server.pem \
  --from-file=cacerts.pem=$DEMO_HOME/certs/component-certs/generated/cacerts.pem \
  --from-file=privkey.pem=$DEMO_HOME/certs/component-certs/generated/connect-server-key.pem \
  --namespace confluent

kubectl create secret generic tls-ksqldb \
  --from-file=fullchain.pem=$DEMO_HOME/certs/component-certs/generated/ksqldb-server.pem \
  --from-file=cacerts.pem=$DEMO_HOME/certs/component-certs/generated/cacerts.pem \
  --from-file=privkey.pem=$DEMO_HOME/certs/component-certs/generated/ksqldb-server-key.pem \
  --namespace confluent
```



### Create a Kubernetes secret object for Control Center authentication credentials & Zookeeper digest
```
kubectl create secret generic credential \
  --from-file=digest-users.json=$DEMO_HOME/creds/creds-zookeeper-sasl-digest-users.json \
  --from-file=digest.txt=$DEMO_HOME/creds/creds-kafka-zookeeper-credentials.txt \
  --from-file=basic.txt=$DEMO_HOME/creds/creds-control-center-users.txt \
  --namespace confluent

```


------

### For Azure key-vault secret

```

az keyvault certificate import --vault-name $AZ_KEYVAULT_NAME \
   -n "cfk-ca-cert-pem" \
   -f $DEMO_HOME/certs/component-certs/generated/cacerts-cert-pkcs8.pem

az keyvault certificate import --vault-name $AZ_KEYVAULT_NAME \
   -n "cfk-kafka-cert-pem" \
   -f $DEMO_HOME/certs/component-certs/generated/kafka-server-cert-pkcs8.pem

az keyvault certificate import --vault-name $AZ_KEYVAULT_NAME \
   -n "cfk-c3-cert-pem" \
   -f $DEMO_HOME/certs/component-certs/generated/controlcenter-server-cert-pkcs8.pem

az keyvault certificate import --vault-name $AZ_KEYVAULT_NAME \
   -n "cfk-schemaregistry-cert-pem" \
   -f $DEMO_HOME/certs/component-certs/generated/schemaregistry-server-cert-pkcs8.pem

az keyvault certificate import --vault-name $AZ_KEYVAULT_NAME \
   -n "cfk-connect-cert-pem" \
   -f $DEMO_HOME/certs/component-certs/generated/connect-server-cert-pkcs8.pem


az keyvault certificate import --vault-name $AZ_KEYVAULT_NAME \
   -n "cfk-ksqldb-cert-pem" \
   -f $DEMO_HOME/certs/component-certs/generated/ksqldb-server-cert-pkcs8.pem

```


### Create a Kubernetes secret object for Control Center authentication credentials & Zookeeper digest
```

az keyvault secret set --vault-name $AZ_KEYVAULT_NAME \
  -n creds-zk-digest-sasl-users-json \
  --file $DEMO_HOME/creds/creds-zookeeper-sasl-digest-users.json

az keyvault secret set --vault-name $AZ_KEYVAULT_NAME \
  -n kafka-zk-digest-creds-txt \
  --file $DEMO_HOME/creds/creds-kafka-zookeeper-credentials.txt

az keyvault secret set --vault-name $AZ_KEYVAULT_NAME \
  -n c3-basic-creds-users-txt \
  --file $DEMO_HOME/creds/creds-control-center-users.txt

```



