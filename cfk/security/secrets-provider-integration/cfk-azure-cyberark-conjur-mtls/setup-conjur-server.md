
### STEP 5: Setup conjur server on conjur namespace:
    DATA_KEY="$(docker run --rm cyberark/conjur data-key generate)"
    HELM_RELEASE_NAME=conjur-oss

    # helm custom-values
    cat > $TUTORIAL_HOME/helm/conjur-server-values.yaml <<EOT
    account:
      name: "myorg"
      create: true
    authenticators: "authn-k8s/namespace,authn-k8s/deployment,authn-k8s/service_account,authn-k8s/dev-cluster,authn"
    dataKey: $DATA_KEY
    ssl:
      caCert: $(cat $TUTORIAL_HOME/files-to-upload/cp-conjur-secrets/cacerts.pem | base64)
      caKey: $(cat $TUTORIAL_HOME/files-to-upload/cp-conjur-secrets/rootCAkey.pem | base64)
      cert: $(cat $TUTORIAL_HOME/files-to-upload/cp-conjur-secrets/conjur-server.pem | base64)
      key: $(cat $TUTORIAL_HOME/files-to-upload/cp-conjur-secrets/conjur-server-key.pem | base64)
      hostname: "conjur.myorg.com"
      altNames:
      - conjur.myorg.com
      - $HELM_RELEASE_NAME
      - $HELM_RELEASE_NAME-ingress
      - $HELM_RELEASE_NAME.conjur.svc.cluster.local
      - $HELM_RELEASE_NAME-ingress.conjur.svc.cluster.local
    loglevl: "debug"
    postgres:
      persistentVolume:
        create: false
    service:
      external:
        enabled: false
    replicaCount: 1
    EOT
#### install conjur server

    helm repo update
    helm install \
      -n "$CONJUR_NAMESPACE" \
      -f helm/conjur-server-values.yaml \
      "$HELM_RELEASE_NAME" \
      https://github.com/cyberark/conjur-oss-helm-chart/releases/download/v$VERSION/conjur-oss-$VERSION.tgz


#### Get Conjur Server pod name
    POD_NAME=$(kubectl get pods --namespace $CONJUR_NAMESPACE \
                        -l "app=$HELM_RELEASE_NAME,release=$HELM_RELEASE_NAME" \
                        -o jsonpath="{.items[0].metadata.name}")

#### Find admin key and make a note of adminkey
    kubectl exec --namespace $CONJUR_NAMESPACE \
              $POD_NAME \
              --container=$HELM_RELEASE_NAME \
              -- conjurctl role retrieve-key myorg:user:admin | tail -1
#### important : make a note of admin api key
    # e.g
    razq3p301891a2etkzd215k02kc2f9zms83jkwckw1701y7g1dkvcm0

-----------