locals {
  primaryHubVnet = {
    name          = "primary-hub-vnet"
    address_space = ["10.0.0.0/16"]
    dns_servers   = ["1.1.1.1"]
    subnets = {
      "GatewaySubnet" = {
        name             = "GatewaySubnet"
        address_prefixes = ["10.0.0.0/24"]
      },
      "RouteServerSubnet" = {
        name             = "RouteServerSubnet"
        address_prefixes = ["10.0.1.0/24"]
      },
      "subnet01" = {
        name             = "hub1-01-gwc-vnet-hubvnet-01-sub-CiscoRouter-1-10.0.2.0_24"
        address_prefixes = ["10.0.2.0/24"]
        network_security_group = {
          id = "/subscriptions/${local.subscription_id_connectivity1}/resourceGroups/${local.primaryHubResourceGroup_name}/providers/Microsoft.Network/networkSecurityGroups/${local.nsg_names.nsg01_name}"
        }
        route_table = {
          id = "/subscriptions/${local.subscription_id_connectivity1}/resourceGroups/${local.primaryHubResourceGroup_name}/providers/Microsoft.Network/routeTables/${local.udr_names.udr01_name}"
        }

        private_endpoint_network_policies_enabled     = true
        private_link_service_network_policies_enabled = true
      },
      "subnet02" = {
        name             = "hub1-01-gwc-vnet-hubvnet-01-sub-CiscoRouter-2-10.0.3.0_24"
        address_prefixes = ["10.0.3.0/24"]
        network_security_group = {
          id = "/subscriptions/${local.subscription_id_connectivity1}/resourceGroups/${local.primaryHubResourceGroup_name}/providers/Microsoft.Network/networkSecurityGroups/${local.nsg_names.nsg01_name}"
        }
        private_endpoint_network_policies_enabled     = true
        private_link_service_network_policies_enabled = true
      },
      "subnet03" = {
        name             = "hub1-01-gwc-vnet-hubvnet-01-sub-CiscoRouter-3-10.0.4.0_24"
        address_prefixes = ["10.0.4.0/24"]
        network_security_group = {
          id = "/subscriptions/${local.subscription_id_connectivity1}/resourceGroups/${local.primaryHubResourceGroup_name}/providers/Microsoft.Network/networkSecurityGroups/${local.nsg_names.nsg01_name}"
        }
        private_endpoint_network_policies_enabled     = true
        private_link_service_network_policies_enabled = true
      },
      "subnet04" = {
        name             = "hub1-01-gwc-vnet-hubvnet-01-sub-CiscoRouter-4-10.0.5.0_24"
        address_prefixes = ["10.0.5.0/24"]
        network_security_group = {
          id = "/subscriptions/${local.subscription_id_connectivity1}/resourceGroups/${local.primaryHubResourceGroup_name}/providers/Microsoft.Network/networkSecurityGroups/${local.nsg_names.nsg01_name}"
        }
        private_endpoint_network_policies_enabled     = true
        private_link_service_network_policies_enabled = true
      }
    }
  }
  secondaryHubVnet = {
    name          = "secondary-hub-vnet"
    address_space = ["10.1.0.0/16"]
    dns_servers   = ["1.0.0.1"]
    subnets = {
      "subnet01" = {
        name             = "subnet01"
        address_prefixes = ["10.1.0.0/24"]
        network_security_group = {
          id = "/subscriptions/${local.subscription_id_connectivity2}/resourceGroups/${local.secondaryHubResourceGroup_name}/providers/Microsoft.Network/networkSecurityGroups/${local.nsg_names.nsg02_name}"
        }
      },
      "subnet02" = {
        name             = "subnet02"
        address_prefixes = ["10.1.1.0/24"]
        network_security_group = {
          id = "/subscriptions/${local.subscription_id_connectivity2}/resourceGroups/${local.secondaryHubResourceGroup_name}/providers/Microsoft.Network/networkSecurityGroups/${local.nsg_names.nsg02_name}"
        }
      },
      "subnet03" = {
        name             = "subnet03"
        address_prefixes = ["10.1.2.0/24"]
        network_security_group = {
          id = "/subscriptions/${local.subscription_id_connectivity2}/resourceGroups/${local.secondaryHubResourceGroup_name}/providers/Microsoft.Network/networkSecurityGroups/${local.nsg_names.nsg02_name}"
        }
      }
    }
  }
  primaryHubNetworkResources = {
    primaryVpnlGW = {
      name            = "primary-hub-VpnlGW"
      gateway_address = "128.9.9.9"
      address_space   = ["192.168.15.0/24"]
      bgp_settings = {
        asn                 = 65050
        peer_weight         = 0
        bgp_peering_address = "10.51.255.254"
      }
    }
    primaryVpnGW_pip01 = {
      name = "primary-hub-VpnGW-pip01"
    }
    primaryVpnGW_pip02 = {
      name = "primary-hub-VpnGW-pip02"
    }
    primaryERGW_pip01 = {
      name = "primary-hub-ERGW-pip01"
    }
    primaryARS_pip01 = {
      name = "primary-hub-ARS-pip01"
    }
    primaryVpnGW = {
      name                    = "primary-hub-VpnGW"
      vpn_type                = "RouteBased"
      sku                     = "VpnGw2AZ"
      generation              = "Generation2"
      ip_configuration_1_name = "primaryHubVPNGatewayIPConfig01"
      ip_configuration_2_name = "primaryHubVPNGatewayIPConfig02"
      bgp_settings = {
        asn         = 65515
        peer_weight = 0
      }
    }

    primaryVpnConnection = {
      name = "primary-hub-VpnConnection"
    }
    primaryERGW = {
      name                    = "primary-hub-ERGW"
      vpn_type                = "RouteBased"
      sku                     = "ErGw1AZ"
      ip_configuration_1_name = "primaryHubERGatewayIPConfig01"
    }
    primaryARS = {
      name = "primary-hub-ARS"
    }
    primaryARS_bgpconnection01 = {
      name     = "primary-hub-ARS-bgpconnection-01"
      peer_asn = 65050
      peer_ip  = "169.254.21.5"
    }
  }
  hub2TOhub1_peering = {
    name = "hub1TOhub2"
  }
  hub1TOhub2_peering = {
    name = "hub2TOhub1"
  }
}
