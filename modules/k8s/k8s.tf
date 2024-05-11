locals {
  cert_manager_name                          = var.k8s_combined_vars["cert_manager_name"]
  cert_manager_repository                    = var.k8s_combined_vars["cert_manager_repository"]
  cert_manager_chart                         = var.k8s_combined_vars["cert_manager_chart"]
  cert_manager_version                       = var.k8s_combined_vars["cert_manager_version"]
  cert_manager_wait                          = var.k8s_combined_vars["cert_manager_wait"]
  cert_manager_set_name                      = var.k8s_combined_vars["cert_manager_set_name"]
  cert_manager_set_value                     = var.k8s_combined_vars["cert_manager_set_value"]
  actions_runner_controller_name             = var.k8s_combined_vars["actions_runner_controller_name"]
  actions_runner_controller_repository       = var.k8s_combined_vars["actions_runner_controller_repository"]
  actions_runner_controller_chart            = var.k8s_combined_vars["actions_runner_controller_chart"]
  actions_runner_controller_namespace        = var.k8s_combined_vars["actions_runner_controller_namespace"]
  actions_runner_controller_create_namespace = var.k8s_combined_vars["actions_runner_controller_create_namespace"]
  actions_runner_controller_wait             = var.k8s_combined_vars["actions_runner_controller_wait"]
  actions_runner_controller_set_name         = var.k8s_combined_vars["actions_runner_controller_set_name"]
  actions_runner_controller_set_value        = var.k8s_combined_vars["actions_runner_controller_set_value"]
  actions_runner_controller_set_github_name  = var.k8s_combined_vars["actions_runner_controller_set_github_name"]
  actions_runner_controller_set_github_value = var.k8s_combined_vars["actions_runner_controller_set_github_value"]
  argocd_name                                = var.k8s_combined_vars["argocd_name"]
  argocd_repository                          = var.k8s_combined_vars["argocd_repository"]
  argocd_chart                               = var.k8s_combined_vars["argocd_chart"]
  argocd_namespace                           = var.k8s_combined_vars["argocd_namespace"]
  argocd_create_namespace                    = var.k8s_combined_vars["argocd_create_namespace"]
  argocd_version                             = var.k8s_combined_vars["argocd_version"]
  ingress_name                               = var.k8s_combined_vars["ingress_name"]
  ingress_repository                         = var.k8s_combined_vars["ingress_repository"]
  ingress_chart                              = var.k8s_combined_vars["ingress_chart"]
  ingress_namespace                          = var.k8s_combined_vars["ingress_namespace"]
  ingress_create_namespace                   = var.k8s_combined_vars["ingress_create_namespace"]
}

provider "helm" {
  kubernetes {
    host                   = var.host
    client_certificate     = base64decode(var.client_certificate)
    client_key             = base64decode(var.client_key)
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

# data "azurerm_storage_blob" "existing_issuer" {
#   count                  = 1
#   name                   = "letsencrypt-staging.yaml"
#   storage_container_name = "letsencrypt-staging"
#   storage_account_name   = "topxsanonprod"
# }
# locals {
#   blob_error = try(data.azurerm_storage_blob.existing_issuer, null)
# }
# data "azurerm_resource_group" "rg" {
#   name = "topx-rg-backend-nonprod-eastus"
# }
# data "azurerm_storage_container" "existing_container" {
#   name                 = "letsencrypt-staging"
#   storage_account_name = "topxsanonprod"
# }
# data "azurerm_storage_account" "storage_account" {
#   name                = "topxsanonprod"
#   resource_group_name = "topx-rg-backend-nonprod-eastus"
# }
# data "azapi_resource_action" "ds" {
#   type                   = "Microsoft.Storage/storageAccounts/blobServices/containers@2023-04-01"
#   resource_id            = data.azurerm_storage_container.existing_container.id
#   method                 = "GET"
#   response_export_values = ["*"]
# }
# locals {
#   resource_list = jsondecode(data.azapi_resource_action.ds.output).value # getting the list of blob

#   blob = [for stg in local.resource_list : stg.name if lower(stg.name) == lower("letsencrypt-staging.yaml")] # getting the blob


#   # Checking to create the storage account or not
#   createBlob = local.blob == null || local.blob == [] ? true : false
# }
resource "null_resource" "local_exec" {
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${var.resource_group_name} --name ${var.cluster_name} --overwrite-existing"
  }
  depends_on = [var.resource_group_name, var.cluster_name]
}



resource "helm_release" "cert_manager" {
  name       = local.cert_manager_name
  repository = local.cert_manager_repository
  chart      = local.cert_manager_chart
  version    = local.cert_manager_version
  wait       = local.cert_manager_wait
  namespace  = local.ingress_namespace
  set {
    name  = local.cert_manager_set_name
    value = local.cert_manager_set_value
  }
  depends_on = [null_resource.local_exec]
}
## Create App Configuration using an external script
resource "null_resource" "app_conf" {
  # provisioner "local-exec" {
  #   command     = "./${path.module}/cert.sh ${self.triggers.storage_account_name} ${self.triggers.container_name} ${self.triggers.blob_name} ${self.triggers.secret_name}"
  #   interpreter = ["bash", "-c"]
  # }
  provisioner "local-exec" {
    command     = <<-EOT
      swapoff -a
      systemctl start crio
      systemctl start kubelet.service
      systemctl stop firewalld.service
      export KUBECONFIG=/etc/kubernetes/admin.conf
      blob_exist=$(az storage blob list -c $container_name --account-name $storage_account_name | jq -e '.[]|select(.name=="letsencrypt-staging.yaml").name')
      if [ -z "$blob_exist" ]; then
          kubectl apply -f ${path.module}/yaml/issuer.yaml --validate=false
          kubectl get secrets $secret_name -o yaml > secret.yaml
          az storage blob upload --account-name $storage_account_name --container-name $container_name --file secret.yaml --name $blob_name --overwrite
      else
          az storage blob download --account-name $storage_account_name --container-name $container_name --name $blob_name --file secret.yaml
          kubectl apply -f secret.yaml --validate=false
      fi
      EOT
    interpreter = ["bash", "-c"]
    environment = {
      storage_account_name = "topxsanonprod"
      container_name       = "letsencrypt-staging"
      blob_name            = "letsencrypt-staging.yaml"
      secret_name          = "letsencrypt-staging"
    }
  }
  # provisioner "local-exec" {
  #     when = destroy
  #     command = "./cert.sh ${self.triggers.storage_account_name} ${self.triggers.container_name} ${self.triggers.blob_name} ${self.triggers.secret_name}" 
  #     interpreter = ["bash", "-c"]
  # }

  depends_on = [
    helm_release.cert_manager
  ]
}

# resource "null_resource" "create_secret_from_blob" {
#   count = local.createBlob ? 0 : 1

#   provisioner "local-exec" {
#     command = <<EOT
#       az storage blob download --account-name topxsanonprod --container-name letsencrypt-staging --name letsencrypt-staging.yaml --file secret.yaml &&
#       kubectl apply -f secret.yaml
#     EOT
#   }
# }
# # CA cluster issuer
# resource "null_resource" "cluster_issuer" {
#   count = local.createBlob ? 1 : 0
#   provisioner "local-exec" {
#     command = "kubectl apply -f ${path.module}/yaml/issuer.yaml"
#   }

#   depends_on = [null_resource.local_exec, helm_release.cert_manager]
# }

# resource "null_resource" "get_secret_and_upload" {
#   count = local.createBlob ? 1 : 0

#   provisioner "local-exec" {
#     command = "kubectl get secrets letsencrypt-staging -o yaml > secret.yaml"
#   }

#   provisioner "local-exec" {
#     command = "az storage blob upload --account-name topxsanonprod --container-name letsencrypt-staging --file secret.yaml --name letsencrypt-staging.yaml"
#   }
#   depends_on = [null_resource.cluster_issuer]
# }

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-controller"
  create_namespace = true

  # set {
  #   name  = "controller.service.annotations.\"service.beta.kubernetes.io/azure-load-balancer-resource-group\""
  #   value = var.public_ip_resource_group
  # }
  # set {
  #   name  = "controller.service.annotations.\"service.beta.kubernetes.io/azure-pip-name\""
  #   value = var.public_ip_name
  # }
  # set {
  #   name  = "controller.service.annotations.\"service.beta.kubernetes.io/azure-dns-label-name\""
  #   value = var.public_ip_dns
  # }
  values     = [file("${path.module}/values/ingress.yaml")]
  depends_on = [null_resource.local_exec]
}
resource "null_resource" "upgrade_ingress_nginx" {
  provisioner "local-exec" {
    command = <<-EOF
      kubectl label namespace ${local.ingress_namespace} cert-manager.io/disable-validation=true
    EOF
  }
  depends_on = [helm_release.ingress_nginx]
}

# ingress services 
resource "null_resource" "ingress_service" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/yaml/microservices.yaml"
  }

  depends_on = [helm_release.ingress_nginx, null_resource.local_exec]
}

# resource "azurerm_storage_blob" "secret_blob" {
#   name                   = "letsencrypt-staging.yaml"
#   storage_container_name = "letsencrypt-staging"
#   storage_account_name   = "topxsanonprod"
#   type                   = "Block"
#   source                 = "secret.yaml"
# }

# resource "helm_release" "cert_manager" {
#   name       = local.cert_manager_name
#   repository = local.cert_manager_repository
#   chart      = local.cert_manager_chart
#   version    = local.cert_manager_version
#   wait       = local.cert_manager_wait
#   namespace  = local.ingress_namespace
#   set {
#     name  = local.cert_manager_set_name
#     value = local.cert_manager_set_value
#   }
#   depends_on = [null_resource.upgrade_ingress_nginx]
# }

# CA cluster issuer
# resource "null_resource" "cluster_issuer" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f ${path.module}/yaml/issuer.yaml"
#   }

#   depends_on = [null_resource.local_exec, helm_release.cert_manager]
# }

# resource "helm_release" "actions_runner_controller" {
#   name             = local.actions_runner_controller_name
#   repository       = local.actions_runner_controller_repository
#   chart            = local.actions_runner_controller_chart
#   namespace        = local.actions_runner_controller_namespace
#   create_namespace = local.actions_runner_controller_create_namespace
#   wait             = local.actions_runner_controller_wait

#   set {
#     name  = local.actions_runner_controller_set_name
#     value = local.actions_runner_controller_set_value
#   }

#   set {
#     name  = local.actions_runner_controller_set_github_name
#     value = local.actions_runner_controller_set_github_value
#   }
#   depends_on = [helm_release.cert_manager]
# }

# resource "helm_release" "argocd" {
#   name = local.argocd_name

#   repository       = local.argocd_repository
#   chart            = local.argocd_chart
#   namespace        = local.argocd_namespace
#   create_namespace = local.argocd_create_namespace
#   version          = local.argocd_version

#   # values     = [file("${path.module}/values/argocd.yaml")]
#   depends_on = [null_resource.local_exec]
# }

# resource "null_resource" "export_git_url" {
#   provisioner "local-exec" {
#     command = "export GIT_URL=$(git config --get remote.origin.url)"
#   }
#   depends_on = [helm_release.argocd]
# }

# resource "null_resource" "export_execute_argo_app" {
#   provisioner "local-exec" {
#     command = "envsubst < modules/k8s/argocd/application/index.yaml | kubectl apply -n argocd -f -"
#   }
#   depends_on = [null_resource.export_git_url]
# }


# # self-hosted runner
# resource "null_resource" "self_hosted_runners" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f ${path.module}/yaml/self-hosted-runner.yaml"
#   }

#   depends_on = [helm_release.actions_runner_controller, null_resource.local_exec]
# }
# # ArgoCD Bootstrap the app of apps 
# resource "null_resource" "argocd_bootstrap" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f ${path.module}/yaml/argocd.yaml"
#   }

#   depends_on = [helm_release.argocd, null_resource.local_exec]
# }

# resource "helm_release" "sonarqube_release" {
#   name = "sonarqube"

#   repository       = "https://SonarSource.github.io/helm-chart-sonarqube"
#   chart            = "sonarqube"
#   namespace        = "sonarqube"
#   create_namespace = true
#   version          = "3.35.4"

#   values     = [file("${path.module}/values/argocd.yaml")]
#   depends_on = [helm_release.cert_manager]
# }


