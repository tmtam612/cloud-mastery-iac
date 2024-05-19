
locals {
  project_name   = var.project_name
  environment    = var.environment
  location       = var.region
  instance_count = var.instance_count
}

#config azure resource group
resource "azurerm_resource_group" "this" {
  name     = "${local.project_name}-${var.resource_group_abbrevation}-${var.resource_group_profile}-${local.environment}-${local.location}-${local.instance_count}"
  location = local.location
}

#config azure user assigned identity
resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  name                = "${var.project_name}-${var.user_assigned_identity_abbrevation}-${var.user_assigned_identity_profile}-${var.environment}-${local.location}-${var.instance_count}"
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_role_assignment" "base" {
  scope                = data.azurerm_resource_group.ip_addresses_resource.id
  role_definition_name = var.network_contributor_role
  principal_id         = azurerm_user_assigned_identity.user_assigned_identity.principal_id
}

resource "azurerm_container_registry" "acr" {
  count               = var.acr_combined_vars.create_acr
  name                = "${var.acr_combined_vars.project_name_without_dash}${var.acr_combined_vars.acr_abbrevation}${var.acr_combined_vars.acr_profile}${var.environment}${local.location}${var.instance_count}"
  resource_group_name = azurerm_resource_group.this.name
  location            = local.location
  sku                 = var.acr_combined_vars.sku
}

resource "azurerm_role_assignment" "acr" {
  count                = var.acr_combined_vars.create_acr
  scope                = azurerm_container_registry.acr.0.id
  role_definition_name = var.default_contributor_role
  principal_id         = azurerm_user_assigned_identity.user_assigned_identity.principal_id
  depends_on = [ azurerm_container_registry.acr ]
}

#config virtual network
module "network" {
  source                = "./modules/network"
  project_name          = local.project_name
  environment           = local.environment
  location              = local.location
  instance_count        = local.instance_count
  resource_group_name   = azurerm_resource_group.this.name
  combined_vars         = var.vnet_combined_vars
  list_subnet           = var.list_subnet
  main_address_space    = var.main_address_space
  subnet1_address_space = var.subnet1_address_space
  subnet2_address_space = var.subnet2_address_space
}

#config  cluster
module "kubernetes" {
  source                 = "./modules/kubernetes"
  location               = local.location
  resource_group_name    = azurerm_resource_group.this.name
  project_name           = local.project_name
  environment            = local.environment
  instance_count         = local.instance_count
  combined_vars          = var.aks_combined_vars
  user_assigned_identity = azurerm_user_assigned_identity.user_assigned_identity.id
  subnet_id              = module.network.subnet1_id
  public_ip_address      = data.azurerm_public_ip.ip_address.id
  depends_on             = [azurerm_role_assignment.base]
}

resource "azurerm_role_assignment" "acr_agentpool" {
  count                = var.acr_combined_vars.create_acr
  scope                = azurerm_container_registry.acr.0.id
  role_definition_name = var.default_contributor_role
  principal_id         = module.kubernetes.node_pool_identity_principal_id
  depends_on           = [ module.kubernetes, azurerm_container_registry.acr ]
}

resource "azurerm_dns_zone" "dns_zone" {
  name                = var.dns_zone
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_role_assignment" "dns_contributor" {
  scope                            = azurerm_dns_zone.dns_zone.id
  role_definition_name             = var.dns_contributor_role
  principal_id                     = module.kubernetes.kube_object_id
  skip_service_principal_aad_check = true # Allows skipping propagation of identity to ensure assignment succeeds.
}

module "k8s" {
  source                   = "./modules/k8s"
  host                     = module.kubernetes.host
  client_certificate       = module.kubernetes.client_certificate
  client_key               = module.kubernetes.client_key
  cluster_ca_certificate   = module.kubernetes.cluster_ca_certificate
  cluster_name             = module.kubernetes.cluster_name
  resource_group_name      = azurerm_resource_group.this.name
  environment              = local.environment
  k8s_depends_on           = [module.kubernetes.host]
  k8s_combined_vars        = merge(var.k8s_combined_vars, {
      public_ip_resource_group    = var.ip_address_resource_group
      public_ip_name              = var.public_ip_address_name
      public_ip_dns               = var.dns_label
      dns_zone                    = var.dns_zone
      subscription_id             = data.azurerm_subscription.current.subscription_id
      identity_client_id          = module.kubernetes.node_pool_identity_client_id
      backend_storge_account_name = var.backend_storge_account_name
      backend_container_name      = var.backend_container_name
      backend_blob_name           = var.backend_blob_name
      backend_secret_name         = var.backend_secret_name
      backend_secret_namespace    = var.backend_secret_namespace
  })
}

