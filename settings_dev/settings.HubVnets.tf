locals {
  primaryHubVnet = {
    name          = "primary-hub-vnet"
    address_space = ["10.0.0.0/16"]
    dns_servers   = ["1.1.1.1"]
    subnets = {
      "GatewaySubnet" = {
        address_prefixes = ["10.0.0.0/24"]
      },
      "RouteServerSubnet" = {
        address_prefixes = ["10.0.1.0/24"]
      },
      "subnet01" = {
        address_prefixes = ["10.0.2.0/24"]
        network_security_group = {
          id = "/subscriptions/${local.subscription_id_connectivity1}/resourceGroups/${local.primaryHubResourceGroup_name}/providers/Microsoft.Network/networkSecurityGroups/${local.nsg_names.nsg01_name}"
        }
        private_endpoint_network_policies_enabled     = true
        private_link_service_network_policies_enabled = true
      },
      "subnet02" = {
        address_prefixes = ["10.0.3.0/24"]
        network_security_group = {
          id = "/subscriptions/${local.subscription_id_connectivity1}/resourceGroups/${local.primaryHubResourceGroup_name}/providers/Microsoft.Network/networkSecurityGroups/${local.nsg_names.nsg01_name}"
        }
        private_endpoint_network_policies_enabled     = true
        private_link_service_network_policies_enabled = true
      },
      "subnet03" = {
        address_prefixes = ["10.0.4.0/24"]
        network_security_group = {
          id = "/subscriptions/${local.subscription_id_connectivity1}/resourceGroups/${local.primaryHubResourceGroup_name}/providers/Microsoft.Network/networkSecurityGroups/${local.nsg_names.nsg01_name}"
        }
        private_endpoint_network_policies_enabled     = true
        private_link_service_network_policies_enabled = true
      },
      "subnet04" = {
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
        address_prefixes = ["10.1.0.0/24"]
      },
      "subnet02" = {
        address_prefixes = ["10.1.1.0/24"]
      },
      "subnet03" = {
        address_prefixes = ["10.1.2.0/24"]
      }
    }
  }
  primaryHubNetworkResources = {
    primaryVpnlGW = {
      name = "primary-hub-VpnlGW"
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
      name       = "primary-hub-VpnConnection"
      shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
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
