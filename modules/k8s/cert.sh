#!/bin/bash

# Azure Blob Storage details
storage_account_name=$1
container_name=$2
blob_name=$3
secret_name=$4
 
blob_exist=$(az storage blob list -c $container_name --account-name $storage_account_name | jq -e '.[]|select(.name==$blob_name).name')
# Check if the blob exists
if [ -z "$blob_exist" ]; then
    az storage blob download --account-name $storage_account_name --container-name $container_name --name $blob_name --file secret.yaml
    kubectl apply -f secret.yaml
    # Run commands if the blob exists
    # For example, you can download the blob using: az storage blob download ...
else
    kubectl apply -f modules/k8s/yaml/issuer.yaml
    kubectl get secrets $secret_name -o yaml > secret.yaml
    az storage blob upload --account-name $storage_account_name --container-name $container_name --file secret.yaml --name blob_name
    # Run commands if the blob does not exist
    # For example, you can create the blob or perform other actions
fi