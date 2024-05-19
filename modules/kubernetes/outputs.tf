output "kube_config" {
  value = azurerm_kubernetes_cluster.cluster.kube_config_raw
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate
}

output "client_key" {
  value = azurerm_kubernetes_cluster.cluster.kube_config.0.client_key
}

output "host" {
  value = azurerm_kubernetes_cluster.cluster.kube_config.0.host
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.cluster.name
}

output "kube_object_id" {
  value = azurerm_kubernetes_cluster.cluster.kubelet_identity.0.object_id
}

output "node_pool_identity_principal_id" {
  value = data.azurerm_user_assigned_identity.node_pool.principal_id
}

output "node_pool_identity_client_id" {
  value = data.azurerm_user_assigned_identity.node_pool.client_id
}