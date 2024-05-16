provider "helm" {
  kubernetes {
    host                   = var.host
    client_certificate     = base64decode(var.client_certificate)
    client_key             = base64decode(var.client_key)
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

resource "null_resource" "local_exec" {
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${var.resource_group_name} --name ${var.cluster_name} --overwrite-existing"
  }
  depends_on = [var.resource_group_name, var.cluster_name]
}



resource "helm_release" "cert_manager" {
  name       = var.k8s_combined_vars["cert_manager_name"]
  repository = var.k8s_combined_vars["cert_manager_repository"]
  chart      = var.k8s_combined_vars["cert_manager_chart"]
  version    = var.k8s_combined_vars["cert_manager_version"]
  wait       = var.k8s_combined_vars["cert_manager_wait"]
  namespace  = var.k8s_combined_vars["ingress_namespace"]
  create_namespace = true
  set {
    name  = var.k8s_combined_vars["cert_manager_set_name"]
    value = var.k8s_combined_vars["cert_manager_set_value"]
  }
  depends_on = [null_resource.local_exec]
}
## Create App Configuration using an external script
resource "null_resource" "create_cert" {
  provisioner "local-exec" {
    command     = <<-EOT
      chmod +x ${path.module}/cert.sh
      ${path.module}/cert.sh ${path.module} ${var.backend_storge_account_name} ${var.backend_container_name} ${var.backend_blob_name}
    EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [
    helm_release.cert_manager
  ]
}

resource "null_resource" "wait_for_certificate" {
  provisioner "local-exec" {
    command = <<-EOT
      container_exist=$(az storage container exists --account-name ${var.backend_storge_account_name} --name ${var.backend_container_name})
      blob_exist=$(az storage blob exists --account-name ${var.backend_storge_account_name} --container-name ${var.backend_container_name} --name ${var.backend_blob_name})
      if [[ $(echo "$blob_exist" | jq -r '.exists') == "false" ]] || [[ $(echo "$container_exist" | jq -r '.exists') == "false" ]]; then
        until kubectl get secret ${var.backend_secret_name} -n ${var.backend_secret_namespace}; do
          echo "Waiting for certificate issuance..."
          sleep 10
        done
        kubectl get secrets ${var.backend_secret_name} -o yaml -n ${var.backend_secret_namespace} > secret.yaml
        az storage blob upload --account-name ${var.backend_storge_account_name} --container-name ${var.backend_container_name} --file secret.yaml --name ${var.backend_blob_name} --overwrite
      fi
    EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [
    null_resource.create_cert,
    null_resource.ingress_service
  ]
}

resource "helm_release" "ingress_nginx" {
  name             = var.k8s_combined_vars["ingress_name"]
  repository       = var.k8s_combined_vars["ingress_repository"]
  chart            = var.k8s_combined_vars["ingress_chart"]
  namespace        = var.k8s_combined_vars["ingress_namespace"]
  create_namespace = true
  values = [templatefile("${path.module}/values/ingress.yaml", {
    resource_group = "${var.public_ip_resource_group}"
    pip_name       = "${var.public_ip_name}"
    dns_name       = "${var.public_ip_dns}"
  })]
  depends_on = [null_resource.local_exec]
}
resource "null_resource" "upgrade_ingress_nginx" {
  provisioner "local-exec" {
    command = <<-EOF
      kubectl label namespace ${var.k8s_combined_vars["ingress_namespace"]} cert-manager.io/disable-validation=true
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

resource "helm_release" "argocd" {
  name = var.k8s_combined_vars["argocd_name"]
  count = var.k8s_combined_vars["argocd_installed_flag"]
  repository       = var.k8s_combined_vars["argocd_repository"]
  chart            = var.k8s_combined_vars["argocd_chart"]
  namespace        = var.k8s_combined_vars["argocd_namespace"]
  create_namespace = var.k8s_combined_vars["argocd_create_namespace"]
  version          = var.k8s_combined_vars["argocd_version"]

  # values     = [file("${path.module}/values/argocd.yaml")]
  depends_on = [null_resource.local_exec, helm_release.ingress_nginx]
}

# resource "helm_release" "actions_runner_controller" {
#   name             = var.k8s_combined_vars["actions_runner_controller_name"]
#   repository       = var.k8s_combined_vars["actions_runner_controller_repository"]
#   chart            = var.k8s_combined_vars["actions_runner_controller_chart"]
#   namespace        = var.k8s_combined_vars["actions_runner_controller_namespace"]
#   create_namespace = var.k8s_combined_vars["actions_runner_controller_create_namespace"]
#   wait             = var.k8s_combined_vars["actions_runner_controller_wait"]

#   set {
#     name  = var.k8s_combined_vars["actions_runner_controller_set_name"]
#     value = var.k8s_combined_vars["actions_runner_controller_set_value"]
#   }

#   set {
#     name  = var.k8s_combined_vars["actions_runner_controller_set_github_name"]
#     value = var.k8s_combined_vars["actions_runner_controller_set_github_value"]
#   }
#   depends_on = [helm_release.cert_manager]
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
#   count = var.k8s_combined_vars["actions_runner_controller_installed_flag"] 
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


