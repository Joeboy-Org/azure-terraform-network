##################################################
# VIRTUAL NETWORK CONFIGURATION
#################################################

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.application_name}-${var.environment_name}"
  location = var.secondary_location != "" ? var.secondary_location : var.primary_location
}

resource "azurerm_virtual_network" "hub_vnets" {
  for_each            = { for key, value in var.hub_vnets : key => value if var.hub_vnets != {} }
  name                = "${each.key}-${var.application_name}-${var.environment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [each.value.hub_base_address_space]
  tags = {
    environment = "hub-${var.environment_name}-vnet"
  }
}

resource "azurerm_virtual_network" "spoke_vnets" {
  for_each            = { for key, value in var.spoke_vnets : key => value if var.spoke_vnets != {} }
  name                = "${each.key}-${var.application_name}-${var.environment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [each.value.spoke_base_address_space]
  tags = {
    environment = "spoke-${var.environment_name}-vnet"
  }
}

##################################################
# VIRTUAL NETWORK CONFIGURATION
#################################################
resource "azurerm_subnet" "hub_subnets" {
  for_each             = { for key, value in local.hub_subnets : key => value if local.hub_subnets != {} }
  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.hub_vnets[each.value.hub_key].name
  address_prefixes     = [each.value.subnet_address_space]
  dynamic "delegation" {
    for_each = { for key, value in each.value.delegation : key => value if each.value.delegation != {} }
    content {
      name = delegation.key
      service_delegation {
        actions = [for value in lookup(delegation.value.service_delegation, "actions") : value]
        name    = delegation.value.service_delegation.name
      }
    }
  }
}

resource "azurerm_subnet" "spoke_subnets" {
  for_each             = { for key, value in local.spoke_subnets : key => value if local.spoke_subnets != {} }
  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.spoke_vnets[each.value.spoke_key].name
  address_prefixes     = [each.value.subnet_address_space]
}


##################################################
# SUBNET SECURITY GROUP ASSOCIATION
#################################################
resource "azurerm_subnet_network_security_group_association" "hub_subnets" {
  for_each                  = { for key, value in local.hub_subnets : key => value if value.name != "AzureBastionSubnet" && value.name != "SubnetDnsInbound" }
  subnet_id                 = azurerm_subnet.hub_subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_subnet_network_security_group_association" "spoke_subnets" {
  for_each                  = { for key, value in local.spoke_subnets : key => value if value.name != "AzureBastionSubnet" }
  subnet_id                 = azurerm_subnet.spoke_subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}