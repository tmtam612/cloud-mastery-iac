
resource "azurerm_dns_zone" "dns_zone" {
  name                = var.dns_zone
  resource_group_name = var.resource_group_name
}

resource "azurerm_dns_a_record" "default_A_record" {
  name                = "${var.project_name}-recordA-${var.combined_vars.record_profile}-${var.environment}-${var.location}-${var.instance_count}"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  target_resource_id  = var.combined_vars.ip_address_id
}

resource "azurerm_role_assignment" "dns_contributor" {
  scope                            = azurerm_dns_zone.dns_zone.id
  role_definition_name             = var.combined_vars.dns_contributor_role
  principal_id                     = var.combined_vars.kube_object_id
  skip_service_principal_aad_check = true # Allows skipping propagation of identity to ensure assignment succeeds.
}
