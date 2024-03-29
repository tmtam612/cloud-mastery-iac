locals {
  azure_kubernetes_abbrevation = var.combined_vars["azure_kubernetes_abbrevation"]
  azure_kubernetes_profile     = var.combined_vars["azure_kubernetes_profile"]
}

# Reference to the AKS cluster
data "azurerm_kubernetes_cluster" "this" {
  name                = "${var.project_name}-${local.azure_kubernetes_abbrevation}-${local.azure_kubernetes_profile}-${var.environment}-${var.location}-${var.instance_count}"
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_kubernetes_cluster.cluster]
}

