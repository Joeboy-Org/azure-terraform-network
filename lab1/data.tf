data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "remote" {
  name                = var.environment_name == "dev" ? "hubvnetA-network-prod" : "hubvnetA-network-dev"
  resource_group_name = var.environment_name == "dev" ? "rg-network-prod" : "rg-network-dev"
}

##########################
# To be looked at later
##########################
# data "azurerm_virtual_network" "remote_hubs" {
#     for_each = var.hub_vnets
#     name                = "${each.key}-${var.application_name}-${var.environment_name == "dev" ? 
#   "prod" : "dev"}"
#     resource_group_name = var.environment_name == "dev" ? "rg-network-prod" : "rg-network-dev"
#   }