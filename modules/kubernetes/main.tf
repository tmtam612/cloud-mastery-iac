locals {
  kubernetes_instance_count      = var.combined_vars["kubernetes_instance_count"]
  aks_abbrevation                = var.combined_vars["aks_abbrevation"]
  aks_profile                    = var.combined_vars["aks_profile"]
  vm_size                        = var.combined_vars["vm_size"]
  node_count                     = var.combined_vars["node_count"]
  aks_dns_prefix                 = var.combined_vars["aks_dns_prefix"]
  aks_identity_type              = var.combined_vars["aks_identity_type"]
  default_node_name              = var.combined_vars["default_node_name"]
  node_pool_name                 = var.combined_vars["node_pool_name"]
  node_priority                  = var.combined_vars["node_priority"]
  sku_tier                       = var.combined_vars["sku_tier"]                  //change to standard when on production
  oidc_issuer_enabled            = var.combined_vars["oidc_issuer_enabled"]       //enable openID connect
  workload_identity_enabled      = var.combined_vars["workload_identity_enabled"] //enable workload identity
  automatic_channel_upgrade      = var.combined_vars["automatic_channel_upgrade"]
  private_cluster_enabled        = var.combined_vars["private_cluster_enabled"]
  enable_auto_scaling            = var.combined_vars["enable_auto_scaling"]
  node_type                      = var.combined_vars["node_type"]
  min_count                      = var.combined_vars["min_count"]
  max_count                      = var.combined_vars["max_count"]
  network_profile_network_plugin = var.combined_vars["network_profile_network_plugin"]
  network_profile_dns_service_ip = var.combined_vars["network_profile_dns_service_ip"]
  network_profile_service_cidr   = var.combined_vars["network_profile_service_cidr"]
  node_resource_group_name       = "${var.project_name}-${var.environment}-${local.node_pool_name}"
}


resource "azurerm_kubernetes_cluster" "cluster" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = "${var.project_name}-${local.aks_abbrevation}-${local.aks_profile}-${var.environment}-${var.location}-${local.kubernetes_instance_count}"
  default_node_pool {
    node_count          = local.node_count
    vm_size             = local.vm_size
    name                = local.default_node_name
    enable_auto_scaling = local.enable_auto_scaling
    type                = local.node_type
    min_count           = local.min_count
    max_count           = local.max_count
    vnet_subnet_id      = var.subnet_id
  }
  dns_prefix                = local.aks_dns_prefix
  sku_tier                  = local.sku_tier                  //change to standard when on production
  oidc_issuer_enabled       = local.oidc_issuer_enabled       //enable openID connect
  workload_identity_enabled = local.workload_identity_enabled //enable workload identity
  automatic_channel_upgrade = local.automatic_channel_upgrade
  private_cluster_enabled   = local.private_cluster_enabled
  node_resource_group       = local.node_resource_group_name

  tags = {
    env = var.environment
  }
  network_profile {
    network_plugin = local.network_profile_network_plugin
    dns_service_ip = local.network_profile_dns_service_ip
    service_cidr   = local.network_profile_service_cidr
    load_balancer_profile {
      outbound_ip_address_ids = [var.public_ip_address]
    }
  }
  lifecycle {
    ignore_changes = [default_node_pool[0].node_count] //when auto scaling, node 0 will not be changed
  }
  identity {
    type         = local.aks_identity_type
    identity_ids = [var.user_assigned_identity]
  }

  depends_on = [var.subnet_id]
}

