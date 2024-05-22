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
}
