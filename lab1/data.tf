# current environment's managed identity
data "azurerm_client_config" "current" {}

# remote environment's managed identity
data "azurerm_user_assigned_identity" "remote" {
  provider            = azurerm.remote
  name                = "github-managed-identity-${local.remote_environment}" # Adjust name pattern
  resource_group_name = "rg-umi-${local.remote_environment}"

}

data "azurerm_virtual_network" "remote" {
  provider            = azurerm.remote
  name                = "hubvnetA-${var.application_name}-${local.remote_environment}"
  resource_group_name = "rg-${var.application_name}-${local.remote_environment}"
}

data "azurerm_private_dns_zone" "remote" {
  provider            = azurerm.remote
  name                = "private${local.remote_environment}.tailoredng.click"
  resource_group_name = "rg-${var.application_name}-${local.remote_environment}"

  depends_on = [
    azurerm_role_assignment.remote_to_local_dns #  remote DNS zone data object to depend on the role assignment
  ]
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

# data "azurerm_virtual_network" "remote" {
#   provider            = azurerm.remote
#   name                = var.environment_name == "dev" ? "hubvnetA-network-prod" : "hubvnetA-network-dev"
#   resource_group_name = var.environment_name == "dev" ? "rg-network-prod" : "rg-network-dev"
# }

# data "azurerm_private_dns_zone" "remote" {
#   provider            = azurerm.remote
#   name                = var.environment_name == "dev" ? "privateprod.tailoredng.click" : "privatedev.tailoredng.click"
#   resource_group_name = var.environment_name == "dev" ? "rg-${var.application_name}-prod" : "rg-${var.application_name}-dev"
# }