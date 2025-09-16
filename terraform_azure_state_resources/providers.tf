provider "azurerm" {
  alias                           = "primary"
  resource_provider_registrations = "none"
  features {}
}

provider "azurerm" {
  alias                           = "secondary"
  resource_provider_registrations = "none"
  features {}
}