### This is a OneTime setup or a prerequisite setup for CFK.
-  Adds/updates necessary helm repo.
-  helm install operator
-  helm install prometheus
-  helm install grafana
-  if you want to change the behaviour, you can update values.yml appropriately before installation for all the helm charts mentioned above.


### Add confluentinc helm repo
helm repo add confluentinc https://packages.confluent.io/helm

### Install Confluent For Kubernetes

  ` helm repo add confluentinc https://packages.confluent.io/helm -n confluent`
   If needed : 
   ` export https_proxy="http://YOUR-PROXY:915"`
   
  ```
helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes --namespace confluent



 helm install confluent-operator  confluentinc/confluent-for-kubernetes --version 0.435.40 -n confluent --set namespaced=false
   
   (or)
   
   helm  install confluent-operator confluentinc/confluent-for-kubernetes --version 0.435.40 -n confluent --set namespaced=true --set namespaceList="{confluent,central,east,west}" 
```
NOTE : To list all the the CFK versions & to compare with CP platrform & kubernetes version compatibility
` helm search repo -l`
  
   NOTE: Please check the --version information passed, CFK has a dependency on K8 Version, Hence select appropriate version for installation.
    Version Compatibility Matrix: https://docs.confluent.io/platform/current/installation/versions-interoperability.html#kubernetes
	
   
#### Verify that operator is running
 `  kubectl get pods -n confluent  ` 


### Add Repositories of  Grafana Prometheus

`helm repo add stable https://charts.helm.sh/stable -n confluent`

`helm repo add grafana https://grafana.github.io/helm-charts -n confluent`

`helm repo update`


### Install Prometheus
```
helm upgrade --install demo-test stable/prometheus \
 --set alertmanager.persistentVolume.enabled=false \
 --set server.persistentVolume.enabled=false \
 --namespace confluent
```


### Install Grafana
helm upgrade --install grafana grafana/grafana --namespace confluent
``


### Ingress ( Optional Step) 

##### Install  for the ssl passthrough (optional step if ingress not enabled on K8 cluster)
```
helm upgrade --install ngress-nginx  stable/nginx-ingress \
  --set rbac.create=true \
  --set controller.publishService.enabled=true \
  --set controller.extraArgs.enable-ssl-passthrough="true" \
  -n confluent
```

