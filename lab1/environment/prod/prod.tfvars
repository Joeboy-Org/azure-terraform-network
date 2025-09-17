environment_name   = "prod"
primary_location   = "australiaeast"
secondary_location = ""



#####################
# Hub Vnet Config
#####################

hub_vnets = {
  "hubvnetA" = {
    hub_base_address_space = "10.200.0.0/22"
    subnets = {
      "SubnetA" = {
        address_prefix = "10.200.0.0/26"
      }
      "SubnetB" = {
        address_prefix = "10.200.0.64/26"
      }
    }
  }
}