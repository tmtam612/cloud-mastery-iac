path_module=$1
echo "$PWD/yaml/issuer.yaml"
blob_exist=$(az storage blob exists --account-name topxsanonprod --container-name letsencrypt-staging --name letsencrypt-staging.yaml)
if [[ $(echo "$blob_exist" | jq -r '.exists') == "true" ]]; then
    echo "Blob exists"
else
    echo "Blob does exists"
    # kubectl apply -f $path_module/yaml/issuer.yaml --validate=false
    # kubectl get secrets letsencrypt-staging -o yaml > secret.yaml
    # az storage blob upload --account-name topxsanonprod --container-name letsencrypt-staging --file secret.yaml --name letsencrypt-staging.yaml --overwrite
fi