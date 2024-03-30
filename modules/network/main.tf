locals {
  virtual_network_abbrevation = var.combined_vars["virtual_network_abbrevation"]
  virtual_network_profile     = var.combined_vars["virtual_network_profile"]
  subnet_abbrevation          = var.combined_vars["subnet_abbrevation"]
  subnet1                     = var.combined_vars["subnet1"]
  subnet2                     = var.combined_vars["subnet2"]
}
resource "azurerm_virtual_network" "this" {
  name                = "${var.project_name}-${local.virtual_network_abbrevation}-${local.virtual_network_profile}-${var.environment}-${var.location}-${var.instance_count}"
  address_space       = var.main_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    env = var.environment
  }
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.project_name}-${local.subnet_abbrevation}-${subnet1}-${var.environment}-${var.location}-${var.instance_count}"
  address_prefixes     = var.subnet1_address_space
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_subnet" "subnet2" {
  name                 = "${var.project_name}-${local.subnet_abbrevation}-${subnet2}-${var.environment}-${var.location}-${var.instance_count}"
  address_prefixes     = var.subnet2_address_space
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
}
# resource "azurerm_virtual_network" "vnet" {
#   name                = "${var.project_name}-${local.virtual_network_abbrevation}-${local.virtual_network_profile}-${var.environment}-${var.location}-${var.instance_count}"
#   address_space       = var.virtual_ip_address
#   location            = var.location
#   resource_group_name = var.resource_group_name

#   tags = {
#     env = var.environment
#   }
# }

# resource "azurerm_subnet" "subnet" {
#   for_each = {
#     for index, sn in var.list_subnet :
#     index => sn
#   }
#   name                 = "${var.project_name}-${local.subnet_abbrevation}-${each.value.name}-${var.environment}-${var.location}-${var.instance_count}"
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = each.value.address_prefix
#   resource_group_name  = var.resource_group_name
#   delegation {
#     name = "subnet-delegation"

#     service_delegation {
#       name    = "Microsoft.Web/serverFarms"
#       actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
#     }
#   }
# }
