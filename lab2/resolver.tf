# DNS Private Resolver
resource "azurerm_private_dns_resolver" "main" {
  count               = var.environment_name == "prod" ? 1 : 0
  name                = "dnsresolver-${var.application_name}-${var.environment_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  virtual_network_id  = azurerm_virtual_network.hub_vnets["HubVnetDns"].id
}

# Inbound Endpoint
resource "azurerm_private_dns_resolver_inbound_endpoint" "main" {
  for_each                = { for key, value in local.hub_subnets : key => value if value.name == "SubnetDnsInbound" && var.environment_name == "prod" }
  name                    = "inbound-endpoint"
  private_dns_resolver_id = azurerm_private_dns_resolver.main[0].id
  location                = azurerm_resource_group.this.location

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.hub_subnets[each.key].id
  }
}

