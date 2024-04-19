
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
  role_definition_name = var.user_assigned_role_definition_name
  principal_id         = azurerm_user_assigned_identity.user_assigned_identity.principal_id
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
  combined_vars          = var.aks_combined_vars
  user_assigned_identity = azurerm_user_assigned_identity.user_assigned_identity.id
  subnet_id              = module.network.subnet1_id
}
module "k8s" {
  source                 = "./modules/k8s"
  host                   = module.kubernetes.host
  client_certificate     = module.kubernetes.client_certificate
  client_key             = module.kubernetes.client_key
  cluster_ca_certificate = module.kubernetes.cluster_ca_certificate
  cluster_name           = module.kubernetes.cluster_name
  resource_group_name    = azurerm_resource_group.this.name
  environment            = local.environment
  k8s_depends_on         = [module.kubernetes.host]
  k8s_combined_vars      = var.k8s_combined_vars
}
