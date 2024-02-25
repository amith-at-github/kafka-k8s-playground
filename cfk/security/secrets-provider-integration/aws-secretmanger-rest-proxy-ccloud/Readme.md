
## Overview
This is a sample Repo demonstrating  CP Rest Proxy deployment on CFK, pointing to Confluent Cloud kafka server and schema Registry. Additionally this repo also supports following features.
-  CFK using csi drivers (container storage interface).
-  CP rest Proxy enabled with Principal propagation.
-  Integrates with AWS secruity Manager.
-  AWS security manager integration is done through csi-secret-store  aws driver.
-  Secret Sync enabled and every 30 seconds (Every 30 seconds , CFK connects to aws Security Manger and looks for latest secrets),
-  aws Secrets are loaded as Kubernetes secret.
-  Terraform scripts create api-key secrets in cCLoud and synch up the secret to aws Security manager.

### NOTE:

-  Confluent Cloud REST-API does not support ( AVRO, protobuf, JsonSchema). Hence during migration of workloads from CP to CC. This is an alternative approach.
-  cCloud works based on Service Account and API-KEY. Every time instead of refreshing secrets using shell scripts.. this is a much cleaner approach in syncing to aws-secret manager.
-  Same concept can be applied for Azure .
-   Auto roll of pods not enabled. Pods have to be manually rolled.


####  Install CFK
    export TUTORIAL_HOME=PWD
    kubectl create namespace confluent

    helm repo add confluentinc https://packages.confluent.io/helm
    helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes

    helm upgrade --install confluent-operator \
      confluentinc/confluent-for-kubernetes \
      --set namespaced=false \
      --set serviceAccount.name=ebs-csi-controller-sa \
      -n confluent

#### Get pods
    kubectl get pods


## SECRET PROVIDER STEPS

#### HELM INSTALL AND CHANGES
    helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
    helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver

    helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws
    helm install -n kube-system secrets-provider-aws aws-secrets-manager/secrets-store-csi-driver-provider-aws

    helm upgrade -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --set enableSecretRotation=true --set rotationPollInterval=300s
    --set syncSecret.enabled=true



### Enable CSI Storage
#### This is per cluster and namespace not needed
    kubectl apply -f $TUTORIAL_HOME/storage/storage.yml -n confluent

### NOTE:
-  Make sure CSI driver add on enabled on EKScluster.
-  Make sure proper ServiceAccount enabled on CP restproxy namespace to make sure it can connect to awsSecurity manager to refresh secrets.

###  Gen CA Pair
    openssl genrsa -out $TUTORIAL_HOME/certs/ca-key.pem 2048

    openssl req -new -key $TUTORIAL_HOME/certs/ca-key.pem -x509 \
      -days 1000 \
      -out $TUTORIAL_HOME/certs/ca.pem \
      -subj "/C=US/ST=CA/L=MountainView/O=Confluent/OU=Operator/CN=TestCA"


    kubectl create secret tls ca-pair-sslcerts \
      --cert=$TUTORIAL_HOME/certs/ca.pem \
      --key=$TUTORIAL_HOME/certs/ca-key.pem -n confluent

###  Create a K8 secret to bootstrap to cCloud and SR
    kubectl apply -f $TUTORIAL_HOME/creds/krp-secrets.yaml -n confluent


## To see errors on secret provider
    kubectl -n kube-system get pods
    kubectl -n kube-system logs pod/<PODID>


### Create secrets in Aws SecretManager using CLI
    aws secretsmanager create-secret \
        --name cfk/secrets-demo/rest-basic-txt \
        --secret-string file://$TUTORIAL_HOME/creds/creds-rest-basic.txt

    aws secretsmanager create-secret \
        --name cfk/secrets-demo/rest-ccloud-jaas-api-access-conf \
        --secret-string file://$TUTORIAL_HOME/creds/creds-rp-ccloud-api-access.conf


### Apply aws-secret-provider configuration
    kubectl apply -f $TUTORIAL_HOME/secret-provider/aws-secrets-provider-rp.yaml -n confluent

### Apply CP rest proxy
    kubectl apply -f $TUTORIAL_HOME/cp.yaml -n confluent




#### NOTE: ALSO check : https://docs.confluent.io/operator/current/co-configure-misc.html 
#### NOTE: for annotation on Roll..  never roll if server is not ready to roll..
#### NOTE:  To roll out clusters.
    kubectl get statefulset --namespace confluent
    kubectl rollout restart statefulset/kafka --namespace confluent

#### Create necessary policy and associate policy to a service account 
    export CLUSTER_NAME=<NAME-OF-CLUSTER>
    export CLUSTER_REGION=ca-central-1

    export NAMESPACE=confluent
    export POLICY_ARN=arn:aws:iam::XXXXXXXX:policy/eksdemo-secretsmanager-policy2
    export CLUSTER_NAME=amith-eks-cfk-amith-CLUSTER-v6

#### USING THIS FOR DEMO
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

## check compatble certs that can be hosted on aws-secrets-manager
openssl x509 -in <PEM FILE> -text

openssl x509 -in $TUTORIAL_HOME/ca-key.pem
openssl x509 -in $TUTORIAL_HOME/ca.pem



## TEAR DOWN

#### DELETE SECRET IN AWS secret manager  
    aws secretsmanager delete-secret --force-delete-without-recovery --secret-id cfk/secrets-demo/rest-basic-txt
    aws secretsmanager delete-secret --force-delete-without-recovery --secret-id cfk/secrets-demo/rest-ccloud-jaas-api-access-conf

    kubectl delete secret cloud-plain cloud-sr-access  ca-pair-sslcerts-n confluent

    helm delete confluent-operator -n confluent



## REFERENCES

-   https://github.com/confluentinc/confluent-kubernetes-examples/blob/master/hybrid/ccloud-integration/README.rst

-  https://github.com/confluentinc/confluent-kubernetes-examples/blob/master/security/configure-with-vault/credentials/zookeeper-server/digest-jaas.conf

- https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver.html

- https://github.com/aws/secrets-store-csi-driver-provider-aws





