resource "azurerm_virtual_network_peering" "peer1_to_peer1" {
  for_each                     = { for key, value in var.hub_vnets : key => value if var.environment_name == "dev" }
  name                         = "${each.key}-${var.application_name}-dev-to-prod"
  resource_group_name          = azurerm_resource_group.this.name
  virtual_network_name         = azurerm_virtual_network.hub_vnets[each.key].name
  remote_virtual_network_id    = data.azurerm_virtual_network.remote.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
resource "azurerm_virtual_network_peering" "peer2_to_peer1" {
  for_each                     = { for key, value in var.hub_vnets : key => value if var.environment_name == "prod" }
  name                         = "${each.key}-${var.application_name}-prod-to-dev"
  resource_group_name          = azurerm_resource_group.this.name
  virtual_network_name         = azurerm_virtual_network.hub_vnets[each.key].name
  remote_virtual_network_id    = data.azurerm_virtual_network.remote.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
