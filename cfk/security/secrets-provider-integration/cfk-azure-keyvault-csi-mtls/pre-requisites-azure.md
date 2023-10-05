### This is a OneTime setup or a prerequisite setup for AZURE AKS & Key Vault.

### AKS 

##### Install azure cli
brew install azure-cli

##### Authenticate with azure cli
az login

export DEMO_HOME=$PWD
export AZ_RESOURCE_GRP_NAME=amith-group-tst
export AZ_REGION=eastus
export AZ_KEYVAULT_NAME=amithazvaulttst
export AKS_CLSTR_NAME=amith-cfk-cluster
export AZ_RSR_GRP_OWNER_EMAIL='owner_email=ammanjunath@confluent.io'

##### Create an group for your AKS
az group create --name $AZ_RESOURCE_GRP_NAME --location $AZ_REGION --tags $AZ_RSR_GRP_OWNER_EMAIL

##### Create a group for another region (optional -not needed)
az group create --name $AZ_RESOURCE_GRP_NAME --location eastus2 

#### Create AZURE KEY VAULT

##### Create or use an azure key value -- vaultname shoudl be unique globally
az keyvault create -n $AZ_KEYVAULT_NAME -g $AZ_RESOURCE_GRP_NAME -l $AZ_REGION

##### also try with --no-self-perms

##### create an example secret (optional)
az keyvault secret set --vault-name $AZ_KEYVAULT_NAME -n MySamplekey --value MyAKSExampleSecret

##### Sample secrets ( optional)
az keyvault secret set --vault-name $AZ_KEYVAULT_NAME -n ccloud-creds-txt --file $DEMO_HOME/ccloud-credentials.txt

az keyvault secret set --vault-name $AZ_KEYVAULT_NAME -n ccloud-creds-txt --file $DEMO_HOME/ccloud-plain-jaas.txt

az keyvault secret set --vault-name $AZ_KEYVAULT_NAME -n plain-jaas-conf --file $DEMO_HOME/plain-jaas.conf

az keyvault certificate get-default-policy > policy.json # get the default policy

az keyvault certificate create --name cert-demo --vault-name $AZ_KEYVAULT_NAME-p "@policy.json"
az keyvault secret set --vault-name $AZ_KEYVAULT_NAME--name "foo" --value "bar"

#### AKS SETUP

## Get different version of k8s supported in aks
az aks get-versions --location $AZ_REGION --output table

## Create your AKS cluster
az aks create --resource-group $AZ_RESOURCE_GRP_NAME --name $AKS_CLSTR_NAME --node-count 6 --zones 1 2 3 --kubernetes-version 1.25.11 --enable-managed-identity --enable-secret-rotation --enable-addons azure-keyvault-secrets-provider  --rotation-poll-interval 1m


## To display output of the AKS cluster creation
 az aks show -g $AZ_RESOURCE_GRP_NAME -n $AKS_CLSTR_NAME 
 az aks show -g $AZ_RESOURCE_GRP_NAME -n $AKS_CLSTR_NAME --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv


## Setup kube config for your cluster
az aks get-credentials --name $AKS_CLSTR_NAME --resource-group $AZ_RESOURCE_GRP_NAME

## ADD labels to nodes - node affinity
kubectl get nodes
kubectl label node aks-nodepool1-21690474-vmss000000 nodeType=non-kafka
kubectl label node aks-nodepool1-21690474-vmss000001 nodeType=non-kafka
kubectl label node aks-nodepool1-21690474-vmss000002 nodeType=non-kafka
kubectl label node aks-nodepool1-21690474-vmss000003 nodeType=kafka
kubectl label node aks-nodepool1-21690474-vmss000004 nodeType=kafka
kubectl label node aks-nodepool1-21690474-vmss000005 nodeType=kafka

## IF needed group into multiple nodepools ( optional )
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --name mynodepool \
    --node-count 3

## list the nodes in Aks
kubectl get nodes
kubectl describe nodes | grep -e "Name:" -e "topology.kubernetes.io/zone"

### OPTOINAL Begins
##Pay attention to the addonProfiles.identity - a managed identity automatically created in the MC_ resource group. We will use this identity to connect to the Azure Key Vault. Let’s save the addonProfiles.identity.cliendId into a variable:


#addonProfiles.azureKeyvaultSecretsProvider.identity.clientId : for UserAssignedIdentities entry in the "secret-provider.yaml"
#When we enable the Azure Key Vault secret provider, the add-on will create a user assigned managed identity in the node managed resource group. Store its resource ID in a variable for later use:

export SERVICE_PRINCIPAL_CLIENT_ID=1ccdc71c-4a9b-45ae-9932-6c8d5892f544


az keyvault set-policy -n $AZ_KEYVAULT_NAME--secret-permissions get --spn $SERVICE_PRINCIPAL_CLIENT_ID
az keyvault set-policy -n $AZ_KEYVAULT_NAME--certificate-permissions get --spn $SERVICE_PRINCIPAL_CLIENT_ID



## To use system-assigned identity
spID=$(az container show \
  --resource-group myResourceGroup \
  --name mycontainer \
  --query identity.principalId --out tsv)
### OPTOINAL Ends


## FOR SYSTEM-assigned identity, Manually using the web UI adminster the follwoing
## Reason is cli login is as a User and system-assigned set-policy spn will fail
-- Go to VMSS , select the appropriate vmss , select identity tab, enable system-assinged to ON.
-- select the Object(principal ID), copy it.
-- GoTO AZ key Vault, select your vault, access-policies, create 
-- select appropriate, search by the copied id (aks-nodepool), and create

### OPTIONAL BEGINS
az vmss identity show -g <resource group>  -n <vmss scalset name> -o yaml
az vm identity show -g <resource group> -n <vm name> -o yaml

az vmss identity show -g $AZ_RESOURCE_GRP_NAME  -n aks-nodepool1-16505438-vmss -o yaml
az vm identity show -g <resource group> -n <vm name> -o yaml
### OPTIONAL BEGINS

## FOR SYSTME-ASSIGNED modify the userAssignedIdetntiyId in secret provider to an empty string.




### kubectl commands (optional - just for test)
kubectl create namespace test
kubectl apply -f $DEMO_HOME/az-keyvault-secrets-provider/azure-secrets-provider.yaml -n test
kubectl apply -f $DEMO_HOME/basic-test/azure-test-pod-4-secrets.yaml -n test
kubectl apply -f $DEMO_HOME/basic-test/azure-test-pod-4-secrets.yaml -n test
kubectl get pods -n test
kubectl -n test exec busybox-secrets-store-inline-system-msi -- ls /mnt/secrets-store/
kubectl -n test exec busybox-secrets-store-inline-system-msi -- cat /mnt/secrets-store/foo
kubectl -n test exec busybox-secrets-store-inline-system-msi -- cat /mnt/secrets-store/cert-demo
kubectl get secrets -n test
 kubectl port-forward controlcenter-0 9021:9021 --namespace=confluent

## Tear Down
kubectl delete -f $DEMO_HOME/az-keyvault-secrets-provider/azure-secrets-provider.yaml -n test
kubectl delete -f $DEMO_HOME/basic-test/azure-test-pod-4-secrets.yaml -n test


## Group delete
az group delete --name $AZ_RESOURCE_GRP_NAME 

######## Azure disk resize (about azure resize , )
https://github.com/Azure/AKS/issues/1477 (azure limitation)
https://github.com/kubernetes-sigs/azuredisk-csi-driver/issues/273 (azure issue)
az feature show --namespace Microsoft.Compute --name LiveResize
https://learn.microsoft.com/en-us/azure/virtual-machines/linux/expand-disks?tabs=azure-cli%2Cubuntu#expand-an-azure-managed-disk

FIX: https://gist.github.com/xnulinu/b3dd729e8d1224bce7f3ed37cae7ee5e

some clusters do not support the allowVolumeExpansion  and ExpandInUsePersistentVolumes  and can’t use the new capabilities of scale up disks
no, I’ve seen it used on other k8s providers
 see above

 Thanks 
@Moshe Blumberg
 - so if the cluster does not support - the properties in (1)  we would need the script ?
If the cluster supports these properties then just updating the "dataVolumeCapacity" in Kafka spec and applying the yml would update the storage in the pod ?

https://docs.confluent.io/operator/current/co-scale-storage.html#expand-storage
https://github.com/confluentinc/confluent-kubernetes-examples/tree/master/scripts
https://github.com/confluentinc/confluent-kubernetes-examples/blob/master/scripts/pv-resize.sh

kubectl get pv -n confluent
./pv-resize.sh -c kafka -t kafka -n confluent -s 6Gi

