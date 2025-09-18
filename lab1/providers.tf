provider "azurerm" {
  resource_provider_registrations = "none"
  features {}
}

provider "azurerm" {
  alias           = "remote"
  subscription_id = var.remote_subscription_id
  features {}
}