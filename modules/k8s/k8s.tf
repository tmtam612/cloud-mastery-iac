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
  set {
    name  = local.cert_manager_set_name
    value = local.cert_manager_set_value
  }
  depends_on = [var.k8s_depends_on, null_resource.local_exec]
}

resource "helm_release" "actions_runner_controller" {
  name             = local.actions_runner_controller_name
  repository       = local.actions_runner_controller_repository
  chart            = local.actions_runner_controller_chart
  namespace        = local.actions_runner_controller_namespace
  create_namespace = local.actions_runner_controller_create_namespace
  wait             = local.actions_runner_controller_wait

  set {
    name  = local.actions_runner_controller_set_name
    value = local.actions_runner_controller_set_value
  }

  set {
    name  = local.actions_runner_controller_set_github_name
    value = local.actions_runner_controller_set_github_value
  }
  depends_on = [helm_release.cert_manager]
}

resource "helm_release" "ingress_nginx" {
  name             = local.ingress_name
  repository       = local.ingress_repository
  chart            = local.ingress_chart
  namespace        = local.ingress_namespace
  create_namespace = local.ingress_create_namespace
}

resource "helm_release" "argocd" {
  name = local.argocd_name

  repository       = local.argocd_repository
  chart            = local.argocd_chart
  namespace        = local.argocd_namespace
  create_namespace = local.argocd_create_namespace
  version          = local.argocd_version

  values     = [file("${path.module}/values/argocd.yaml")]
  depends_on = [helm_release.cert_manager]
}

# self-hosted runner
resource "null_resource" "self_hosted_runners" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/yaml/self-hosted-runner.yaml"
  }

  depends_on = [helm_release.actions_runner_controller, null_resource.local_exec]
}
# ArgoCD Bootstrap the app of apps 
resource "null_resource" "argocd_bootstrap" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/yaml/argocd.yaml"
  }

  depends_on = [helm_release.argocd, null_resource.local_exec]
}

# ingress services 
resource "null_resource" "ingress_service" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/yaml/ingress.yaml"
  }

  depends_on = [helm_release.ingress_nginx, null_resource.local_exec]
}

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


