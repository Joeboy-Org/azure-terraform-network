# resource "azurerm_private_dns_zone" "private" {
#   name                = "private${var.environment_name}.tailoredng.click"
#   resource_group_name = azurerm_resource_group.this.name
# }


# #################################################
# # DEV PRIVATE DNS ZONE CONFIG
# #################################################

# resource "azurerm_private_dns_zone_virtual_network_link" "hub_vnet_dev" {
#   for_each              = { for key, value in var.hub_vnets : key => value if var.environment_name == "dev" }
#   name                  = "dnsvnetlink-${var.application_name}-${var.environment_name}"
#   resource_group_name   = azurerm_resource_group.this.name
#   private_dns_zone_name = azurerm_private_dns_zone.private.name # Dev RG (where dev DNS zone lives)
#   virtual_network_id    = azurerm_virtual_network.hub_vnets[each.key].id
#   registration_enabled  = true
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "hub_vnet_dev_to_remote_prod" {
#   provider              = azurerm.remote
#   for_each              = { for key, value in var.hub_vnets : key => value if var.environment_name == "dev" }
#   name                  = "${var.environment_name}-to-${local.remote_environment}-dnsvnetlink"
#   resource_group_name   = "rg-${var.application_name}-prod" # Prod RG (where prod DNS zone lives)
#   private_dns_zone_name = data.azurerm_private_dns_zone.remote.name
#   virtual_network_id    = azurerm_virtual_network.hub_vnets[each.key].id

# }


# #################################################
# # PROD PRIVATE DNS ZONE CONFIG
# #################################################

# resource "azurerm_private_dns_zone_virtual_network_link" "hub_vnet_prod" {
#   for_each              = { for key, value in var.hub_vnets : key => value if var.environment_name == "prod" }
#   name                  = "dnsvnetlink-${var.application_name}-${var.environment_name}"
#   resource_group_name   = azurerm_resource_group.this.name # Prod RG (where dev DNS zone lives)
#   private_dns_zone_name = azurerm_private_dns_zone.private.name
#   virtual_network_id    = azurerm_virtual_network.hub_vnets[each.key].id
#   registration_enabled  = true
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "hub_vnet_prod_to_remote_dev" {
#   provider              = azurerm.remote ### using this provider because a change is made in the target resource..If it was done on the current resource there wont be need
#   for_each              = { for key, value in var.hub_vnets : key => value if var.environment_name == "prod" }
#   name                  = "${var.environment_name}-to-${local.remote_environment}-dnsvnetlink"
#   resource_group_name   = "rg-${var.application_name}-dev" # Dev RG (where dev DNS zone lives)
#   private_dns_zone_name = data.azurerm_private_dns_zone.remote.name
#   virtual_network_id    = azurerm_virtual_network.hub_vnets[each.key].id
# }