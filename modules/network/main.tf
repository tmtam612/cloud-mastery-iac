resource "azurerm_virtual_network" "this" {
  name                = "${var.project_name}-${var.combined_vars["virtual_network_abbrevation"]}-${var.combined_vars["virtual_network_profile"]}-${var.environment}-${var.location}-${var.instance_count}"
  address_space       = var.main_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    env = var.environment
  }
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.project_name}-${var.combined_vars["subnet_abbrevation"]}-${var.combined_vars["subnet1"]}-${var.environment}-${var.location}-${var.instance_count}"
  address_prefixes     = var.subnet1_address_space
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
}

# resource "azurerm_subnet" "subnet2" {
#   name                 = "${var.project_name}-${local.subnet_abbrevation}-${local.subnet2}-${var.environment}-${var.location}-${var.instance_count}"
#   address_prefixes     = var.subnet2_address_space
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.this.name
# }
