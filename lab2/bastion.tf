#################################
## AZURE BASTION CONFIURATION
#################################


resource "azurerm_public_ip" "bastion" {
  for_each            = { for key, value in local.spoke_subnets : key => value if value.name == "AzureBastionSubnet" && var.environment_name == "dev" }
  name                = "pip-${var.application_name}-${var.environment_name}-bastion"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "main" {
  for_each            = { for key, value in local.spoke_subnets : key => value if value.name == "AzureBastionSubnet" && var.environment_name == "dev" }
  name                = "bas-${var.application_name}-${var.environment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.spoke_subnets[each.key].id
    public_ip_address_id = azurerm_public_ip.bastion[each.key].id
  }
}