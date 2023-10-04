### Deploy cert-manager v1.0.2 does not work

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.10.1/cert-manager.yaml

kubectl api-versions | grep admission


helm install cert-manager jetstack/cert-manager --namespace cert-manager --set installCRDs=true


### Using a CA issuer
kubectl -k $DEMO_HOME/cert-manager/ca apply


#### Check issuer
kubectl -n confluent get issuers
#### Check certificate
kubectl -n confluent get certificates


### Using Self Signed Certificate
kubectl -k $DEMO_HOME/cert-manager/self-signed apply

If you need to change the certificate SAN or secret names, change the file cert-manager/self-signed/certificate.yaml. The provided certificate.yaml is configured with namespace confluent and an opinionated name choices for Confluent Platform.

Check issuers: kubectl -n confluent get issuers

Check certificates: kubectl -n confluent get certificates

####
kubectl -n confluent get secrets

#### The secret names can be checked with output of 
kubectl -n confluent get certificates

### Valiate
#### Status
kubectl -n confluent get kafka -oyaml
kubectl -n confluent get zookeeper -oyaml
kubectl -n confluent get schemaregistry -oyaml
kubectl -n confluent get ksqldb -oyaml
kubectl -n confluent get connect -oyaml
kubectl -n confluent get controlcenter -oyaml

### Tear Down
kubectl delete -f $DEMO_HOME/resources/
kubectl delete -k  $DEMO_HOME/cert-manager/ca
kubectl delete -k  $DEMO_HOME/cert-manager/self-signed

kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.10.1/cert-manager.yaml

