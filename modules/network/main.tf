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

resource "azurerm_network_security_group" "nsg" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # security_rule {
  #   name                       = "test123"
  #   priority                   = 100
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "*"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }

  # tags = {
  #   environment = "Production"
  # }
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# resource "azurerm_subnet" "subnet2" {
#   name                 = "${var.project_name}-${local.subnet_abbrevation}-${local.subnet2}-${var.environment}-${var.location}-${var.instance_count}"
#   address_prefixes     = var.subnet2_address_space
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.this.name
# }
