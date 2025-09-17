resource "azurerm_network_security_group" "nsg1" {
  name                = "nsg1-${var.application_name}-${var.environment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule = []

  tags = {
    environment = "nsg-${var.environment_name}"
  }
}

