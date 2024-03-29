provider "helm" {
  kubernetes {
    host                   = var.host
    client_certificate     = base64decode(var.client_certificate)
    client_key             = base64decode(var.client_key)
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.14.0"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "actions_runner_controller" {
  name             = "actions-runner-controller"
  repository       = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart            = "actions-runner-controller"
  namespace        = "actions-runner-controller"
  create_namespace = true
  wait             = true

  set {
    name  = "authSecret.create"
    value = "true"
  }

  set {
    name  = "authSecret.github_token"
    value = "<your-PAT>"
  }
  depends_on = [helm_release.cert_manager]
}

# self-hosted controller
resource "null_resource" "self_hosted_runners" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/yaml/self-hosted-runner.yaml"
  }

  depends_on = [helm_release.actions_runner_controller]
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "3.35.4"

  values     = [file("${path.module}/values/argocd.yaml")]
  depends_on = [helm_release.cert_manager]
}

# ArgoCD Bootstrap the app of apps 
resource "null_resource" "argocd_bootstrap" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/yaml/argocd.yaml"
  }

  depends_on = [helm_release.argocd]
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


