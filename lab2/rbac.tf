# resource "azurerm_role_assignment" "user" {
#   scope                = azurerm_key_vault.main.id
#   role_definition_name = "Key Vault Administrator"
#   principal_id         = data.azurerm_client_config.current.object_id #current environment's managed identity
# }


# ##############################
# # USER MANAGED IDENTITY
# ##############################

# resource "azurerm_user_assigned_identity" "vm" {
#   location            = azurerm_resource_group.this.location
#   name                = "vm-umi-${var.application_name}-${var.environment_name}"
#   resource_group_name = azurerm_resource_group.this.name
# }

# resource "azurerm_role_assignment" "vm_managed_identity" {
#   scope                = azurerm_key_vault.main.id
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = azurerm_user_assigned_identity.vm.principal_id
# }


# Grant remote managed identity permission to peer VNets
resource "azurerm_role_assignment" "spoke_to_hub_peer" {
  count                = var.environment_name == "dev" ? 1 : 0 # Add this
  scope                = azurerm_virtual_network.spoke_vnets["SpokeVnetDns"].id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_user_assigned_identity.remote.principal_id
}

resource "azurerm_role_assignment" "hub_to_spoke_peer" {
  count                = var.environment_name == "prod" ? 1 : 0 # Add this
  scope                = azurerm_virtual_network.hub_vnets["HubVnetDns"].id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_user_assigned_identity.remote.principal_id
}