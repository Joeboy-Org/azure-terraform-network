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
  name                = "${local.remote_vnet}-${var.application_name}-${local.remote_environment}"
  resource_group_name = "rg-${var.application_name}-${local.remote_environment}"
  depends_on = [
    azurerm_virtual_network.spoke_vnets,
    azurerm_virtual_network.hub_vnets,
    azurerm_role_assignment.spoke_to_hub_peer,
    azurerm_role_assignment.hub_to_spoke_peer

  ]
}

data "azurerm_private_dns_zone" "remote" {
  provider            = azurerm.remote
  count               = var.environment_name == "dev" ? 1 : 0
  name                = "private${local.remote_environment}.tailoredng.click"
  resource_group_name = "rg-${var.application_name}-${local.remote_environment}"

  depends_on = [
    azurerm_role_assignment.remote_to_local_dns #  remote DNS zone data object to depend on the role assignment
  ]
}

data "azurerm_private_dns_resolver" "remote" {
  provider            = azurerm.remote
  count               = var.environment_name == "dev" ? 1 : 0
  name                = "dnsresolver-${var.application_name}-${local.remote_environment}"
  resource_group_name = "rg-${var.application_name}-${local.remote_environment}"
}

data "azurerm_private_dns_resolver_inbound_endpoint" "remote" {
  provider                = azurerm.remote
  count                   = var.environment_name == "dev" ? 1 : 0
  name                    = "inbound-endpoint"
  private_dns_resolver_id = data.azurerm_private_dns_resolver.remote[0].id
}