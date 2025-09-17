environment_name   = "dev"
primary_location   = "australiaeast"
secondary_location = "australiasoutheast"

#####################
# Hub Vnet Config
#####################

hub_vnets = {
  "hubvnetA" = {
    hub_base_address_space = "10.100.0.0/22"
    subnets = {
      "AzureBastionSubnet" = {
        address_prefix = "10.100.0.0/26"
      }
      "SubnetA" = {
        address_prefix = "10.100.0.64/26"
      }
      "SubnetB" = {
        address_prefix = "10.100.0.128/26"
      }
    }
  }
}