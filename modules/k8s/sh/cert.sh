path_module=$1
storage_account_name=$2
container_name=$3
blob_name=$4
export AZURE_ZONE_NAME=$5
export AZURE_RESOURCE_GROUP=$6
export AZURE_SUBSCRIPTION_ID=$7
export IDENTITY_CLIENT_ID=$8
export ACME_STAGING_SERVER_URL=$9
export ACME_SERVER_URL=$10
export EMAIL=$11

envsubst < $PWD/$path_module/yaml/issuer.yaml | kubectl apply --validate=false -f -
blob_exist=$(az storage blob exists --account-name $storage_account_name --container-name $container_name --name $blob_name)
if ! kubectl get namespace ingress-service; then
    kubectl create namespace ingress-service
fi
# Set values for dnsNames
export DNS_NAME=$12
export DNS_NAME_WILDCARD=$13
envsubst < $PWD/$path_module/yaml/certificate.yaml | kubectl apply --validate=false -f -
if [[ $(echo "$blob_exist" | jq -r '.exists') == "true" ]]; then
    az storage blob download --account-name $storage_account_name --container-name $container_name  --name $blob_name --file secret.yaml
    if ! kubectl get namespace ingress-service; then
        kubectl create namespace ingress-service
    fi
    kubectl apply -f secret.yaml --validate=false
fi