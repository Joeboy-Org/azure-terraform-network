##################################################
# Storage Account
#################################################

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.application_name}-${var.environment_name}"
  location = var.secondary_location != "" ? var.secondary_location : var.primary_location
}

resource "random_string" "suffix" {
  length  = 10
  upper   = false
  special = false
}
resource "azurerm_storage_account" "main" {
  name                     = "st${random_string.suffix.result}${var.environment_name}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate${var.environment_name}"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "tfplan" {
  name                  = "tfplan${var.environment_name}"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}



# ##################################################
# # Storage Account Prod
# #################################################

# resource "azurerm_resource_group" "prod" {
#   provider = azurerm.primary
#   name     = "rg-${var.application_name}-${var.environment_name}"
#   location = var.primary_location
# }

# resource "azurerm_storage_account" "prod" {
#   provider                 = azurerm.primary
#   name                     = "st${random_string.suffix.result}${var.environment_name}"
#   resource_group_name      = azurerm_resource_group.prod.name
#   location                 = azurerm_resource_group.prod.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
# }

# resource "azurerm_storage_container" "tfstate_prod" {
#   provider              = azurerm.primary
#   name                  = "tfstate${var.environment_name}"
#   storage_account_id    = azurerm_storage_account.prod.id
#   container_access_type = "private"
# }

# resource "azurerm_storage_container" "tfplan_prod" {
#   provider              = azurerm.primary
#   name                  = "tfplan${var.environment_name}"
#   storage_account_id    = azurerm_storage_account.prod.id
#   container_access_type = "private"
# }