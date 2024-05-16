path_module=$1
storage_account_name=$2
container_name=$3
blob_name=$4
echo "$PWD/modules/k8s/yaml/issuer.yaml"
blob_exist=$(az storage blob exists --account-name $storage_account_name --container-name $container_name --name $blob_name)
kubectl apply -f $PWD/$path_module/yaml/issuer.yaml --validate=false
if [[ $(echo "$blob_exist" | jq -r '.exists') == "true" ]]; then
    az storage blob download --account-name $storage_account_name --container-name $container_name  --name $blob_name --file secret.yaml
    if ! kubectl get namespace ingress-service; then
        kubectl create namespace ingress-service
    fi
    kubectl apply -f secret.yaml --validate=false
    kubectl apply -f $PWD/$path_module/yaml/certificate.yaml --validate=false
fi