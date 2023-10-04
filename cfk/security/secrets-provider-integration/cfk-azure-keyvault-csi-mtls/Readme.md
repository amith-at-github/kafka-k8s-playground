cd <PATH-TO-PROJECT>/cfk-azure-keyvault-csi-mtls
export DEMO_HOME=$PWD

# Regarding the project workspace
- This is a sample Repository for running confluent kafka with MTLS AuthN & AuthZ Acls.
- This repo also showcases Azure KeyVault to Kubernetes Secrets Sync up (secrets & certificates)
- RackAware is enabled. 
- Connector has externalized secrets.

# PreRequisites & pre setup Steps
 - file to follow [pre-requisites-azure.md](pre-requisites-azure.md)


## Create Necessary Namespace and make sure it is on Right project
1) Create  a namesapce "confluent" within project.
2) Create following namespaces 
     - confluent
      kubectl create namespace  confluent


# **STEP 1: Helm chart install**
 - file to follow [pre-requisites.md](pre-requisites.md)

# **STEP 2: Create SSL certificates**
#### Create necessary certificates for the project 
  - Refer file  [certs-configurations.md](certs-configurations.md) for the steps. 
  NOTE: This step assumes all generated certifiates are in /generated folder.

# **STEP 3: Create secrets** (NO need to run for azure)
####  Create secrets for the generated certificates and place the certificates in its respective namespaces.
####  File to use [create-ssl-secrets.md](create-ssl-secrets.md)
#### For Azure key vault integraiton, create AZ keyvault certs (dependency on pkcs8) no need to create k8s secrets ( it is automaticaly created by secrets provider)	




# **STEP 4: (Deploy confluent platform)**

#### Install cp platform components
```
kubectl apply -f $DEMO_HOME/az-keyvault-secrets-provider/azure-secrets-provider.yaml -n confluent

kubectl apply -f $DEMO_HOME/basic-test/azure-test-pod-4-secrets.yaml -n confluent (important bootstrap, without this secrets will not be created)

kubectl apply -f $DEMO_HOME/role-binding/serviceaccount-rolebinding.yml -n confluent

kubectl apply -f $DEMO_HOME/cp-az-mtls-rackaware-keyvault-secretsync.yml

```

Verify Rack awareness by
kubectl apply -f $DEMO_HOME/role-binding/serviceaccount-rolebinding.yml -n confluent
kubectl exec -it kafka-0 -n confluent -- \
  grep 'broker.rack' confluentinc/etc/kafka/kafka.properties

NOTE:  YOu will notice that only Zookeeper and Kafka will start up . Rest of the CP components will fail due to non availbility of ACL's


# **STEP 5: (create admin.properties for acl commands)**

```
cat <<-EOF > /opt/confluentinc/admin.properties
bootstrap.servers=kafka.east.svc.cluster.local:9071
security.protocol=SSL
ssl.keystore.location=/mnt/sslcerts/keystore.p12
ssl.keystore.password=mystorepassword
ssl.truststore.location=/mnt/sslcerts/truststore.p12
ssl.truststore.password=mystorepassword
EOF
```


# **STEP 6: (create ACL's for CP components)**

####  Certs created are for "User:Kafka, User:sr, User:connect, User:ksql , User:c3"
#### Run commands listed in [acl-commands.md](acl-commands.md)
- this file is customized and reflects the common Schema topic, connect topic for MRC clusters
- the commands in this file can be directly run (execute shell) on any one of the kafka pods.


# **STEP 7: ( internal validation)**
## once ACL's are set all the other components should start running ( SR, connect, ksqldb, C3)

### port forward
kubectl port-forward controlcenter-0 9021:9021 --namespace=east

### Grafana Port Foward.
```
kubectl get pods -n confluent ( get the pod name of grafana)
kubectl port-forward <GRAFANA_POD_NAME> 3000:3000 -n confluent
```



#### Get admin Passowrd
`kubectl get secret --namespace confluent grafana -o jsonpath="{.data.admin-password}" | base64 --decode`
- Another way to get password is from Rancher Secrets, look for grafana



## Configure Grafana with a prometheus Data source.
http://demo-test-prometheus-server.confluent.svc.cluster.local

## import grafana dashboards from "grafana-dashboard" folder. 
- There are two json files.
- import the files
- select prometheus as the datasource


# **STEP 8: Install ingress**
 
```
kubectl apply -f $DEMO_HOME/networking/ingress-service-hostbased.yaml -n confluent
kubectl apply -f $DEMO_HOME/networking/ingress-cp-bootstrap-service.yaml -n confluent
```


## update local Host file

```
10.110.17.170  kafka.confluent-dev.amith.com fm0.confluent-dev.amith.com c3.confluent-dev.amith.com ksqldb.confluent-dev.amith.com connect.confluent-dev.amith.com schema.confluent-dev.amith.com

```


## Validate with  kafkacat for ingress (external client access)

### For mtls have to provide key -X ssl.key.location
kafkacat -b kafka.confluent-dev.amith.com:443 \
-X security.protocol=SSL  \
-X ssl.ca.location=$DEMO_HOME/certs/component-certs/generated/cacerts.pem \
-X ssl.key.location=$DEMO_HOME/certs/component-certs/generated/kafka-server-key.pem \
-X ssl.certificate.location=$DEMO_HOME/certs/component-certs/generated/kafka-server.pem \
-L

## Validate all the CP components from chrome.
```
- https://c3.confluent-dev.amith.com
- https://schema.confluent-dev.amith.com
- https://ksqldb.confluent-dev.amith.com
- https://connect.confluent-dev.amith.com
```


## if mtls enabled on CP components:
```
curl --key $DEMO_HOME/certs/component-certs/generated/connect-server-key.pem   \
   --cert $DEMO_HOME/certs/component-certs/generated/connect-server.pem  \
   --cacert $DEMO_HOME/certs/component-certs/generated/cacerts.pem  \
   https://connect.confluent-dev.amith.com


curl --key $DEMO_HOME/certs/component-certs/generated/ksqldb-server-key.pem   \
   --cert $DEMO_HOME/certs/component-certs/generated/ksqldb-server.pem  \
   --cacert $DEMO_HOME/certs/component-certs/generated/cacerts.pem  \
     https://ksqldb.confluent-dev.amith.com/info
  

curl --key $DEMO_HOME/certs/component-certs/generated/schemaregistry-server-key.pem   \
   --cert $DEMO_HOME/certs/component-certs/generated/schemaregistry-server.pem  \
   --cacert $DEMO_HOME/certs/component-certs/generated/cacerts.pem  \
    https://schema.confluent-dev.amith.com
```


## Miscellaneous commands
### kubectl commands
```
kubectl get pods -n confluent
kubectl get svc -n confluent
kubectl get sc
kubectl explain kafka.spec
kubectl describe pod <POD_NAME> -n namespace
kubectl logs <POD_NAME> -n namespace
```


### zookeeper commands
```
echo "ruok" | nc localhost 2181
echo "stat" | nc localhost 2181
echo "mntr" | nc localhost 2181
echo "srvr" | nc localhost 2181
```



### RACK AWARENESS: CHEcking command
```
kubectl get node \
  -o=custom-columns=NODE:.metadata.name,ZONE:.metadata.labels."topology\.kubernetes\.io/zone" \
  | sort -k2

```


# **STEP 9: TEAR DOWN**

## Tear Down/Delete cp platform components

```
kubectl delete -f $DEMO_HOME/az-keyvault-secrets-provider/azure-secrets-provider.yaml -n confluent
kubectl delete -f $DEMO_HOME/cp-az-mtls-rackaware-keyvault-secretsync.yml -n confluent


kubectl delete -f $DEMO_HOME/networking/ingress-service-hostbased.yaml -n confluent
kubectl delete -f $DEMO_HOME/networking/ingress-cp-bootstrap-service.yaml -n confluent
```



## Tear Down/Delete secrets

```
kubectl delete secret  credential tls-kafka tls-schemaregistry tls-connect tls-ksqldb  tls-controlcenter -n confluent

```


## Tear Down/Delete confluent-operator prometheus grafana ingress-nginx

```
helm uninstall confluent-operator -n confluent
helm uninstall demo-test -n confluent
helm uninstall grafana -n confluent

```

## Azure Group delete
look in pre-requisite-azure.md

## Troubleshooting.
### To check internal (inside k8 cluster CP componentes are working)
#### Open a shell on any of the CP pods on Rancher and invoke curl
```
- curl -k  https://schemaregistry.east.svc.cluster.local:8081
- curl -k https://connect.east.svc.cluster.local:8083
- curl -k https://ksqldb.east.svc.cluster.local:8088/info
```

## init container logs for connect
`kubectl logs -f connect1-0 -c config-init-container -n east`

## To calculate SHA for a downloaded zip file
`certutil -hashfile splunk-kafka-connect-splunk-2.0.8.zip SHA512`


## References
 
[References.md](References.md)

