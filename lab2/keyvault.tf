# resource "random_string" "keyvault_suffix" {
#   length  = 6
#   upper   = false
#   special = false
# }


# resource "azurerm_key_vault" "main" {
#   name                      = "kv-${var.application_name}-${var.environment_name}-${random_string.keyvault_suffix.result}"
#   location                  = azurerm_resource_group.this.location
#   resource_group_name       = azurerm_resource_group.this.name
#   tenant_id                 = data.azurerm_client_config.current.tenant_id
#   sku_name                  = "standard"
#   enable_rbac_authorization = true
#   purge_protection_enabled  = false
# }