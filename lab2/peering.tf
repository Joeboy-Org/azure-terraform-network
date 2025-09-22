# resource "azurerm_virtual_network_peering" "hub_to_spoke" {
#   for_each                     = { for key, value in var.hub_vnets : key => value if var.environment_name == "prod" }
#   name                         = "${each.key}-${var.application_name}-hub-to-spoke"
#   resource_group_name          = azurerm_resource_group.this.name
#   virtual_network_name         = azurerm_virtual_network.hub_vnets[each.key].name
#   remote_virtual_network_id    = data.azurerm_virtual_network.remote.id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true
# }

# resource "azurerm_virtual_network_peering" "spoke_to_hub" {
#   for_each                     = { for key, value in var.spoke_vnets : key => value if var.environment_name == "dev" }
#   name                         = "${each.key}-${var.application_name}-spoke-to-hub"
#   resource_group_name          = azurerm_resource_group.this.name
#   virtual_network_name         = azurerm_virtual_network.spoke_vnets[each.key].name
#   remote_virtual_network_id    = data.azurerm_virtual_network.remote.id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true
# }
