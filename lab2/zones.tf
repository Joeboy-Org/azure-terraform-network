resource "azurerm_private_dns_zone" "private" {
  count               = var.environment_name == "prod" ? 1 : 0
  name                = "private${var.environment_name}.tailoredng.click"
  resource_group_name = azurerm_resource_group.this.name
}


#################################################
# PROD PRIVATE DNS ZONE CONFIG
#################################################

resource "azurerm_private_dns_zone_virtual_network_link" "hub_vnet_prod" {
  for_each              = { for key, value in var.hub_vnets : key => value if var.environment_name == "prod" }
  name                  = "dnsvnetlink-${var.application_name}-${var.environment_name}"
  resource_group_name   = azurerm_resource_group.this.name # Prod RG (where dev DNS zone lives)
  private_dns_zone_name = azurerm_private_dns_zone.private[0].name
  virtual_network_id    = azurerm_virtual_network.hub_vnets[each.key].id
  registration_enabled  = true
}

resource "azurerm_private_dns_a_record" "app" {
  count               = var.environment_name == "prod" ? 1 : 0
  name                = "app"
  zone_name           = azurerm_private_dns_zone.private[0].name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  records             = ["10.200.0.192"]
}