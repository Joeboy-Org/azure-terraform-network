locals {
  # Flatten hub subnets for each hub VNet
  hub_subnets = merge([
    for hub_key, hub_config in var.hub_vnets : {
      for subnet_name, subnet_config in lookup(hub_config, "subnets", {}) :
      "${hub_key}-${subnet_name}" => {
        name                 = subnet_name
        subnet_address_space = subnet_config.address_prefix
        delegation           = subnet_config.delegation
        hub_key              = hub_key
      }
    }
  ]...)

  # Flatten spoke subnets for each spoke VNet
  spoke_subnets = merge([
    for spoke_key, spoke_config in var.spoke_vnets : {
      for subnet_name, subnet_config in lookup(spoke_config, "subnets", {}) :
      "${spoke_key}-${subnet_name}" => {
        name                 = subnet_name
        subnet_address_space = subnet_config.address_prefix
        spoke_key            = spoke_key
      }
    }
  ]...)

  remote_environment = var.environment_name == "dev" ? "prod" : "dev"
  remote_vnet        = var.environment_name == "dev" ? "HubVnetDns" : "SpokeVnetDns"
  key_vault_roles    = ["Key Vault Administrator", "Key Vault Secrets User"]

  # dns_config_script = var.environment_name == "dev" ? templatefile("${path.module}/script/configure-dns-server.tpl", {
  #   azure_dns_endpoint       = data.azurerm_private_dns_resolver_inbound_endpoint.remote.ip_configurations[0].private_ip_address
  #   spoke_server_a           = azurerm_linux_virtual_machine.spoke_vmA[0].private_ip_address
  #   spoke_server_b           = azurerm_linux_virtual_machine.spoke_vmB[0].private_ip_address
  #   local_domain             = "tailoredng.local"
  #   azure_domain             = data.azurerm_private_dns_zone.remote[0].name
  #   hub_base_address_space   = "10.200.0.0/22"
  #   spoke_base_address_space = "192.168.0.0/22"
  # }) : ""
}