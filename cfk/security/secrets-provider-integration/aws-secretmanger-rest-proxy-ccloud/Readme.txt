Reference:


Refer: https://github.com/confluentinc/confluent-kubernetes-examples/blob/master/hybrid/ccloud-integration/README.rst

export TUTORIAL_HOME=PWD
kubectl create namespace confluent

helm repo add confluentinc https://packages.confluent.io/helm
helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes

helm upgrade --install confluent-operator \
  confluentinc/confluent-for-kubernetes \
  --set namespaced=false \
  --set serviceAccount.name=ebs-csi-controller-sa \
  -n confluent


kubectl get pods

### Enable CSI Storage
# THis is per cluster and namespace not needed
kubectl apply -f $TUTORIAL_HOME/storage/storage.yml -n confluent



#Gen CA Pair
openssl genrsa -out $TUTORIAL_HOME/certs/ca-key.pem 2048

openssl req -new -key $TUTORIAL_HOME/certs/ca-key.pem -x509 \
  -days 1000 \
  -out $TUTORIAL_HOME/certs/ca.pem \
  -subj "/C=US/ST=CA/L=MountainView/O=Confluent/OU=Operator/CN=TestCA"


kubectl create secret tls ca-pair-sslcerts \
  --cert=$TUTORIAL_HOME/certs/ca.pem \
  --key=$TUTORIAL_HOME/certs/ca-key.pem -n confluent


kubectl apply -f $TUTORIAL_HOME/creds/krp-secrets.yaml -n confluent




## SECRET PROVIDER STEPS

## HELM INSTALL AND CHANGES
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver

helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws
helm install -n kube-system secrets-provider-aws aws-secrets-manager/secrets-store-csi-driver-provider-aws

helm upgrade -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --set enableSecretRotation=true --set rotationPollInterval=300s
--set syncSecret.enabled=true


## To see errors
kubectl -n kube-system get pods
kubectl -n kube-system logs pod/<PODID>



aws secretsmanager create-secret \
    --name cfk/secrets-demo/rest-basic-txt \
    --secret-string file://$TUTORIAL_HOME/creds/creds-rest-basic.txt

aws secretsmanager create-secret \
    --name cfk/secrets-demo/rest-ccloud-jaas-api-access-conf \
    --secret-string file://$TUTORIAL_HOME/creds/creds-rp-ccloud-api-access.conf



kubectl apply -f $TUTORIAL_HOME/secret-provider/aws-secrets-provider-rp.yaml -n confluent


kubectl apply -f $TUTORIAL_HOME/cp.yaml -n confluent




## ALSO check : https://docs.confluent.io/operator/current/co-configure-misc.html 
## for annotation on Roll..  never roll if server is not ready to roll..
###  To roll out clusters.
kubectl get statefulset --namespace confluent
kubectl rollout restart statefulset/kafka --namespace confluent


export CLUSTER_NAME=<NAME-OF-CLUSTER>
export CLUSTER_REGION=ca-central-1

export NAMESPACE=confluent
export POLICY_ARN=arn:aws:iam::XXXXXXXX:policy/eksdemo-secretsmanager-policy2
export CLUSTER_NAME=amith-eks-cfk-amith-CLUSTER-v6

## USING THIS FOR DEMO
POLICY_ARN=$(aws --region "$CLUSTER_REGION" --query Policy.Arn --output text iam create-policy --policy-name eksdemo-secretsmanager-policy1 --policy-document '{
    "Version": "2012-10-17",
    "Statement": [ {
        "Effect": "Allow",
        "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        "Resource": "*"
    } ]
}')


echo $POLICY_ARN



eksctl create iamserviceaccount --name eksdemo-secretmanager-sa3 --region="$CLUSTER_REGION" --cluster "$CLUSTER_NAME" --namespace="$NAMESPACE" --attach-policy-arn "$POLICY_ARN" --approve --override-existing-serviceaccounts


## TEAR DOWN

## DELETE SECRET IN AWS secret manager  
aws secretsmanager delete-secret --force-delete-without-recovery --secret-id cfk/secrets-demo/rest-basic-txt
aws secretsmanager delete-secret --force-delete-without-recovery --secret-id cfk/secrets-demo/rest-ccloud-jaas-api-access-conf

kubectl delete secret cloud-plain cloud-sr-access  ca-pair-sslcerts-n confluent

helm delete confluent-operator -n confluent



## REFERENCES
# REFER : https://github.com/confluentinc/confluent-kubernetes-examples/blob/master/security/configure-with-vault/credentials/zookeeper-server/digest-jaas.conf

## check compatble certs that can be hosted on aws-secrets-manager
openssl x509 -in <PEM FILE> -text

openssl x509 -in $TUTORIAL_HOME/ca-key.pem
openssl x509 -in $TUTORIAL_HOME/ca.pem


https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver.html

https://github.com/aws/secrets-store-csi-driver-provider-aws
