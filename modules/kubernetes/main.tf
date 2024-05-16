resource "azurerm_kubernetes_cluster" "cluster" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = "${var.project_name}-${var.combined_vars["aks_abbrevation"]}-${var.combined_vars["aks_profile"]}-${var.environment}-${var.location}-${var.instance_count}"
  default_node_pool {
    node_count          = var.combined_vars["node_count"]
    vm_size             = var.combined_vars["vm_size"]
    name                = var.combined_vars["default_node_name"]
    enable_auto_scaling = var.combined_vars["enable_auto_scaling"]
    type                = var.combined_vars["node_type"]
    min_count           = var.combined_vars["min_count"]
    max_count           = var.combined_vars["max_count"]
    vnet_subnet_id      = var.subnet_id
  }
  dns_prefix                = var.combined_vars["aks_cloudmastery_dns_prefix"]
  sku_tier                  = var.combined_vars["sku_tier"]                  //change to standard when on production
  oidc_issuer_enabled       = var.combined_vars["oidc_issuer_enabled"]       //enable openID connect
  workload_identity_enabled = var.combined_vars["workload_identity_enabled"] //enable workload identity
  automatic_channel_upgrade = var.combined_vars["automatic_channel_upgrade"]
  private_cluster_enabled   = var.combined_vars["private_cluster_enabled"]
  node_resource_group       = "${var.project_name}-${var.environment}-${var.combined_vars["node_pool_name"]}-${var.instance_count}"

  tags = {
    env = var.environment
  }
  network_profile {
    network_plugin = var.combined_vars["network_profile_network_plugin"]
    dns_service_ip = var.combined_vars["network_profile_dns_service_ip"]
    service_cidr   = var.combined_vars["network_profile_service_cidr"]
    load_balancer_profile {
      outbound_ip_address_ids = [var.public_ip_address]
    }
  }
  lifecycle {
    ignore_changes = [default_node_pool[0].node_count] //when auto scaling, node 0 will not be changed
  }
  identity {
    type         = var.combined_vars["aks_identity_type"]
    identity_ids = [var.user_assigned_identity]
  }

  depends_on = [var.subnet_id]
}

