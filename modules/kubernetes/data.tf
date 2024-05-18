data "azurerm_user_assigned_identity" "node_pool" {
  depends_on = [ azurerm_kubernetes_cluster.cluster ]
  resource_group_name = "${var.project_name}-${var.environment}-${var.aks_combined_vars["node_pool_name"]}-${var.instance_count}"
  name = "${var.project_name}-${var.aks_combined_vars["aks_abbrevation"]}-${var.aks_combined_vars["aks_profile"]}-${var.environment}-${var.location}-${var.instance_count}-agentpool"
}