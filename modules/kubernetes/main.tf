locals {
  kubernetes_instance_count = var.combined_vars["kubernetes_instance_count"]
  node_pool_instance_count  = var.combined_vars["node_pool_instance_count"]
  node_pool_profile         = var.combined_vars["node_pool_profile"]
  node_pool_abbrevation     = var.combined_vars["node_pool_abbrevation"]
  aks_abbrevation           = var.combined_vars["aks_abbrevation"]
  aks_profile               = var.combined_vars["aks_profile"]
  vm_size                   = var.combined_vars["vm_size"]
  node_count                = var.combined_vars["node_count"]
  aks_dns_prefix            = var.combined_vars["aks_dns_prefix"]
  aks_identity_type         = var.combined_vars["aks_identity_type"]
  default_node_name         = var.combined_vars["default_node_name"]
  node_pool_name            = var.combined_vars["node_pool_name"]
  node_priority             = var.combined_vars["node_priority"]
}


resource "azurerm_kubernetes_cluster" "cluster" {
  location                  = var.location
  resource_group_name       = var.resource_group_name
  name                      = "${var.project_name}-${local.aks_abbrevation}-${local.aks_profile}-${var.environment}-${var.location}-${local.kubernetes_instance_count}"
  private_cluster_enabled   = false
  automatic_channel_upgrade = "stable"
  default_node_pool {
    enable_auto_scaling = false
    node_count          = local.node_count
    vm_size             = local.vm_size
    name                = local.default_node_name
  }
  dns_prefix                = local.aks_dns_prefix
  sku_tier                  = "Free"
  oidc_issuer_enabled       = true //enable openID connect
  workload_identity_enabled = true //enable workload identity

  tags = {
    env = var.environment
  }

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count] //when auto scaling, node 0 will not be changed
  }
  identity {
    type         = local.aks_identity_type
    identity_ids = [var.user_assigned_identity]
  }

}

