###############################
# HUB VM CONFIG
###############################


resource "random_password" "hub_vm_password" {
  count            = var.environment_name == "prod" ? 1 : 0
  length           = 16
  special          = true
  override_special = "_%@"
}

#Store the password in key vault secrets
resource "azurerm_key_vault_secret" "hub_vm_secret" {
  count        = var.environment_name == "prod" ? 1 : 0
  name         = "hubvm-private-password-${var.application_name}-${var.environment_name}"
  value        = random_password.hub_vm_password[0].result
  key_vault_id = azurerm_key_vault.main.id
}


resource "azurerm_network_interface" "hub_nicA" {
  for_each            = { for key, value in local.hub_subnets : key => value if value.name == "SubnetA" && var.environment_name == "prod" }
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
  for_each            = { for key, value in local.hub_subnets : key => value if value.name == "SubnetB" && var.environment_name == "prod" }
  name                = "hub-nicB-${var.application_name}-${var.environment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_subnets[each.key].id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_windows_virtual_machine" "hubvmA" {
  count                 = var.environment_name == "prod" ? 1 : 0
  name                  = "hubvmA${var.application_name}${var.environment_name}"
  computer_name         = "hubvmA-${substr(var.environment_name, 0, 4)}"
  resource_group_name   = azurerm_resource_group.this.name
  location              = azurerm_resource_group.this.location
  size                  = "Standard_B2ms"
  admin_username        = "adminuser"
  admin_password        = random_password.hub_vm_password[0].result
  network_interface_ids = [for key, value in azurerm_network_interface.hub_nicA : value.id]

  identity {
    type         = "UserAssigned"
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


resource "azurerm_windows_virtual_machine" "hubvmB" {
  count = var.environment_name == "prod" ? 1 : 0

  name                  = "hubvmB${var.application_name}${var.environment_name}"
  computer_name         = "hubvmB-${substr(var.environment_name, 0, 4)}"
  resource_group_name   = azurerm_resource_group.this.name
  location              = azurerm_resource_group.this.location
  size                  = "Standard_B2ms"
  admin_username        = "adminuser"
  admin_password        = random_password.hub_vm_password[0].result
  network_interface_ids = [for key, value in azurerm_network_interface.hub_nicB : value.id]

  identity {
    type         = "UserAssigned"
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


###############################
# Spoke VM CONFIG
###############################

resource "tls_private_key" "this" {
  count     = var.environment_name == "dev" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Store the ssh key in key vault secrets
resource "azurerm_key_vault_secret" "spoke_vm_private" {
  count        = var.environment_name == "dev" ? 1 : 0
  name         = "spoke-vm-ssh-private"
  value        = tls_private_key.this[0].private_key_pem
  key_vault_id = azurerm_key_vault.main.id
}
resource "azurerm_key_vault_secret" "spoke_vm_public" {
  count        = var.environment_name == "dev" ? 1 : 0
  name         = "spoke-vm-ssh-public"
  value        = tls_private_key.this[0].public_key_openssh
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_public_ip" "spoke_vmA" {
  count               = var.environment_name == "dev" ? 1 : 0
  name                = "pip-${var.application_name}-${var.environment_name}-spoke-vmA"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "spoke_nicA" {
  for_each            = { for key, value in local.spoke_subnets : key => value if value.name == "SubnetA" && var.environment_name == "dev" }
  name                = "spoke-nicA-${var.application_name}-${var.environment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.spoke_subnets[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.spoke_vmA[0].id
  }
}

resource "azurerm_network_interface" "spoke_nicB" {
  for_each            = { for key, value in local.spoke_subnets : key => value if value.name == "SubnetB" && var.environment_name == "dev" }
  name                = "spoke-nicB-${var.application_name}-${var.environment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke_subnets[each.key].id
    private_ip_address_allocation = "Dynamic"
  }
}

# resource "azurerm_linux_virtual_machine" "spoke_vmA" {
#   count               = var.environment_name == "dev" ? 1 : 0
#   name                = "spokevmA${var.application_name}-${var.environment_name}"
#   resource_group_name = azurerm_resource_group.this.name
#   location            = azurerm_resource_group.this.location
#   size                = "Standard_B2s"
#   admin_username      = "adminuser"
#   network_interface_ids = [
#     for key, value in azurerm_network_interface.spoke_nicA : value.id
#   ]
#   identity {
#     type = "SystemAssigned"
#   }
#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = tls_private_key.this[0].public_key_openssh
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }

#   # Custom script to install BIND
#   custom_data = base64encode(templatefile("${path.module}/script/configure-dns-server.tpl", {
#     azure_dns_endpoint       = data.azurerm_private_dns_resolver_inbound_endpoint.remote[0].ip_configurations[0].private_ip_address
#     spoke_server_a           = azurerm_network_interface.spoke_nicA[keys(azurerm_network_interface.spoke_nicA)[0]].private_ip_address
#     spoke_server_b           = azurerm_network_interface.spoke_nicB[keys(azurerm_network_interface.spoke_nicB)[0]].private_ip_address
#     local_domain             = "tailoredng.local"
#     azure_domain             = data.azurerm_private_dns_zone.remote[0].name
#     hub_base_address_space   = "10.200.0.0/22"
#     spoke_base_address_space = "192.168.0.0/22"
#   }))
# }
resource "azurerm_linux_virtual_machine" "spoke_vmB" {
  count               = var.environment_name == "dev" ? 1 : 0
  name                = "spokevmB${var.application_name}-${var.environment_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  network_interface_ids = [
    for key, value in azurerm_network_interface.spoke_nicB : value.id
  ]
  identity {
    type = "SystemAssigned"
  }
  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.this[0].public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}