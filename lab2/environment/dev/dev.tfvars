environment_name   = "dev"
primary_location   = "australiaeast"
secondary_location = "australiasoutheast"

#####################
# Hub Vnet Config
#####################

spoke_vnets = {
  "SpokeVnetDns" = {
    spoke_base_address_space = "192.168.0.0/22"
    subnets = {
      "AzureBastionSubnet" = {
        address_prefix = "192.168.0.0/26"
      }
      "SubnetA" = {
        address_prefix = "192.168.0.64/26"
      }
      "SubnetB" = {
        address_prefix = "192.168.0.128/26"
      }
    }
  }
  "SpokeVnetB" = {
    spoke_base_address_space = "192.169.10.0/22"
    subnets = {
      "SubnetA" = {
        address_prefix = "192.169.10.0/26"
      }
      "SubnetB" = {
        address_prefix = "192.169.10.64/26"
      }
    }
  }
}