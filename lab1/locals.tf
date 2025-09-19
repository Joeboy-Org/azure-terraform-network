locals {
  # Flatten hub subnets for each hub VNet
  hub_subnets = merge([
    for hub_key, hub_config in var.hub_vnets : {
      for subnet_name, subnet_config in lookup(hub_config, "subnets", {}) :
      "${hub_key}-${subnet_name}" => {
        name                 = subnet_name
        subnet_address_space = subnet_config.address_prefix
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

  #   refactored_vnet_config = merge({
  #     for hub_key, hub_config in var.hub_vnets : "${hub_key}" => {
  #         hub_key              = hub_key
  #         primary_environment_name = "dev"
  #         secondary_environment_name = "prod"
  #       }
  # }...)
}