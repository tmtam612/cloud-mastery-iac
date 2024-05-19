data "azurerm_resource_group" "ip_addresses_resource" {
  name = var.ip_address_resource_group
}
data "azurerm_public_ip" "ip_address" {
  name                = var.public_ip_address_name
  resource_group_name = var.ip_address_resource_group
}
data "azurerm_subscription" "current" {
}