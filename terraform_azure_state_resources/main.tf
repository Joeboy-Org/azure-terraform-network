resource "azurerm_resource_group" "dev" {
  name     = "rg-${var.application_name}-${var.environment_name}"
  location = var.secondary_location
}

resource "random_string" "suffix" {
  length  = 10
  upper   = false
  special = false
}
resource "azurerm_storage_account" "dev" {
  name                     = "st${random_string.suffix.result}${var.environment_name}"
  resource_group_name      = azurerm_resource_group.dev.name
  location                 = azurerm_resource_group.dev.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "tfstate_dev" {
  name                  = "tfstate${var.environment_name}"
  storage_account_id    = azurerm_storage_account.dev.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "tfplan_dev" {
  name                  = "tfplan${var.environment_name}"
  storage_account_id    = azurerm_storage_account.dev.id
  container_access_type = "private"
}



##################################################
# Storage Account Prod
#################################################

resource "azurerm_resource_group" "prod" {
  name     = "rg-${var.application_name}-${var.environment_name}"
  location = var.primary_location
}

resource "azurerm_storage_account" "prod" {
  name                     = "st${random_string.suffix.result}${var.environment_name}"
  resource_group_name      = azurerm_resource_group.prod.name
  location                 = azurerm_resource_group.prod.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "tfstate_prod" {
  name                  = "tfstate${var.environment_name}"
  storage_account_id    = azurerm_storage_account.prod.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "tfplan_prod" {
  name                  = "tfplan${var.environment_name}"
  storage_account_id    = azurerm_storage_account.prod.id
  container_access_type = "private"
}