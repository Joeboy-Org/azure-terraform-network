resource "azurerm_role_assignment" "user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id #current environment's managed identity
}


##############################
# USER MANAGED IDENTITY
##############################

resource "azurerm_user_assigned_identity" "vm" {
  location            = azurerm_resource_group.this.location
  name                = "vm-umi-${var.application_name}-${var.environment_name}"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_role_assignment" "vm_managed_identity" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.vm.principal_id
}


# Grant remote managed identity permission to link VNets to local DNS zone
resource "azurerm_role_assignment" "remote_to_local_dns" {
  scope                = azurerm_private_dns_zone.private.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = data.azurerm_user_assigned_identity.remote.principal_id
}