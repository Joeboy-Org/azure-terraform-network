###############################
# HUB VM CONFIG
###############################


resource "random_password" "vm_password" {
  length = 16
  special = true
  override_special = "_%@"
}

#Store the password in key vault secrets
resource "azurerm_key_vault_secret" "secret" {
  name         = "vm-private-password-${var.application_name}-${var.environment_name}"
  value        = random_password.vm_password.result
  key_vault_id = azurerm_key_vault.main.id
}


resource "azurerm_network_interface" "hub_nicA" {
  for_each = { for key, value in local.hub_subnets : key => value if value.name == "SubnetA"}
  name                = "hub-nicA-${var.application_name}-${var.environment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_subnets[each.key].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "hub_nicB" {
  for_each = { for key, value in local.hub_subnets : key => value if value.name == "SubnetB"}
  name                = "hub-nicB-${var.application_name}-${var.environment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_subnets[each.key].id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_windows_virtual_machine" "vmA" {
  name                = "vmA${var.application_name}${var.environment_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = random_password.vm_password.result
  network_interface_ids = [ for key, value in azurerm_network_interface.hub_nicA : value.id]

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.vm.id]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}


resource "azurerm_windows_virtual_machine" "vmB" {
  name                = "vmB${var.application_name}${var.environment_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = random_password.vm_password.result
  network_interface_ids = [ for key, value in azurerm_network_interface.hub_nicB : value.id]

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.vm.id]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
