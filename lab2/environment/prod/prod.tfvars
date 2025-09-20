environment_name   = "prod"
primary_location   = "australiaeast"
secondary_location = ""



#####################
# Hub Vnet Config
#####################

hub_vnets = {
  "HubVnetDns" = {
    hub_base_address_space = "10.200.0.0/22"
    subnets = {
      "SubnetA" = {
        address_prefix = "10.200.0.0/26"
        delegation     = {}
      }
      "SubnetB" = {
        address_prefix = "10.200.0.64/26"
        delegation     = {}
      }
      "SubnetDnsInbound" = {
        address_prefix = "10.200.0.128/26"
        delegation = {
          dns_delgation = {
            name = "dns_delgation"
            service_delegation = {
              actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
              name    = "Microsoft.Network/dnsResolvers"
            }
          }
        }
      }
    }
  }
}