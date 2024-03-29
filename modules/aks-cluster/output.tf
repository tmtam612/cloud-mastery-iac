output "host" {
  value = data.azurerm_kubernetes_cluster.this.kube_config.0.host
}
output "client_certificate" {
  value = data.azurerm_kubernetes_cluster.this.kube_config.0.client_certificate
}
output "client_key" {
  value = data.azurerm_kubernetes_cluster.this.kube_config.0.client_key
}
output "cluster_ca_certificate" {
  value = data.azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate
}
