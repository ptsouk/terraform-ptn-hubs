# import settings
module "settings" {
  source = "./settings_dev"
}

# deploy primary hub resource group in the specified location.
resource "azurerm_resource_group" "primaryHubResourceGroup" {
  provider = azurerm.subscription_id_connectivity1
  location = module.settings.default.primary_location
  name     = module.settings.default.primaryHubResourceGroup_name
  tags     = module.settings.default_tags
}

# deploy secondary hub resource group in the specified location.
resource "azurerm_resource_group" "secondaryHubResourceGroup" {
  provider = azurerm.subscription_id_connectivity2
  location = module.settings.default.secondary_location
  name     = module.settings.default.secondaryHubResourceGroup_name
  tags     = module.settings.default_tags
}

module "nsg01" {
  providers = {
    azurerm = azurerm.subscription_id_connectivity1
  }
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup
  ]
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.2.0"
  enable_telemetry    = true
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name
  name                = module.settings.NSGRules.nsg_names.nsg01_name
  location            = module.settings.default.primary_location
  security_rules      = module.settings.NSGRules.nsg_rules.nsg01_rules
  tags                = module.settings.default_tags
}

module "nsg02" {
  providers = {
    azurerm = azurerm.subscription_id_connectivity2
  }
  depends_on = [
    azurerm_resource_group.secondaryHubResourceGroup
  ]
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.2.0"
  enable_telemetry    = true
  resource_group_name = azurerm_resource_group.secondaryHubResourceGroup.name
  name                = module.settings.NSGRules.nsg_names.nsg02_name
  location            = module.settings.default.secondary_location
  security_rules      = module.settings.NSGRules.nsg_rules.nsg02_rules
  tags                = module.settings.default_tags
}

# deploy hub 1
module "primaryHubVnet" {
  providers = {
    azurerm = azurerm.subscription_id_connectivity1
  }
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup,
    module.nsg01
  ]
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.1.4"
  enable_telemetry    = true
  name                = module.settings.HubVnets.primaryHubVnet.name
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name
  location            = module.settings.default.primary_location
  subnets             = module.settings.HubVnets.primaryHubVnet.subnets
  virtual_network_dns_servers = {
    dns_servers = module.settings.HubVnets.primaryHubVnet.dns_servers
  }
  virtual_network_address_space = module.settings.HubVnets.primaryHubVnet.address_space
  tags                          = module.settings.default_tags
}
# deploy hub 2
module "secondaryHubVnet" {
  providers = {
    azurerm = azurerm.subscription_id_connectivity2
  }
  depends_on = [
    azurerm_resource_group.secondaryHubResourceGroup,
    module.nsg02
  ]
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.1.4"
  enable_telemetry    = true
  name                = module.settings.HubVnets.secondaryHubVnet.name
  resource_group_name = azurerm_resource_group.secondaryHubResourceGroup.name
  location            = module.settings.default.secondary_location
  subnets             = module.settings.HubVnets.secondaryHubVnet.subnets
  virtual_network_dns_servers = {
    dns_servers = module.settings.HubVnets.secondaryHubVnet.dns_servers
  }
  virtual_network_address_space = module.settings.HubVnets.secondaryHubVnet.address_space
  tags                          = module.settings.default_tags
}

resource "azurerm_local_network_gateway" "primaryVpnlGW" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup
  ]
  name                = "primary-hub-VpnlGW"
  location            = module.settings.default.primary_location
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name
  gateway_address     = "128.9.9.9"
  address_space       = ["192.168.15.0/24"]
  bgp_settings {
    asn                 = 65050
    peer_weight         = 0
    bgp_peering_address = "10.51.255.254"
  }
  tags = module.settings.default_tags
}

resource "azurerm_public_ip" "primaryVpnGW_pip01" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup
  ]
  name                = "primary-hub-VpnGW-pip01"
  location            = module.settings.default.primary_location
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = module.settings.default_tags
}

resource "azurerm_public_ip" "primaryVpnGW_pip02" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup
  ]
  name                = "primary-hub-VpnGW-pip02"
  location            = module.settings.default.primary_location
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = module.settings.default_tags
}

resource "azurerm_public_ip" "primaryERGW_pip01" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup
  ]
  name                = "primary-hub-ERGW-pip01"
  location            = module.settings.default.primary_location
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = module.settings.default_tags
}

resource "azurerm_public_ip" "primaryARS_pip01" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup
  ]
  name                = "primary-hub-ARS-pip01"
  location            = module.settings.default.primary_location
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = module.settings.default_tags
}

resource "azurerm_virtual_network_gateway" "primaryVpnGW" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    module.primaryHubVnet,
    azurerm_public_ip.primaryVpnGW_pip01,
    azurerm_public_ip.primaryVpnGW_pip02
  ]
  name                = "primary-hub-VpnGW"
  location            = module.settings.default.primary_location
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = true
  enable_bgp    = true
  sku           = "VpnGw2"
  generation    = "Generation2"

  ip_configuration {
    name                          = "primaryHubVPNGatewayIPConfig01"
    public_ip_address_id          = azurerm_public_ip.primaryVpnGW_pip01.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = module.primaryHubVnet.subnets.GatewaySubnet.id
  }

  ip_configuration {
    name                          = "primaryHubVPNGatewayIPConfig02"
    public_ip_address_id          = azurerm_public_ip.primaryVpnGW_pip02.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = module.primaryHubVnet.subnets.GatewaySubnet.id
  }

  bgp_settings {
    asn         = 65515
    peer_weight = 0
  }
  tags = module.settings.default_tags
}

resource "azurerm_virtual_network_gateway_connection" "primaryVpnConnection" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_virtual_network_gateway.primaryVpnGW,
    azurerm_local_network_gateway.primaryVpnlGW
  ]
  name                       = "primary-hub-VpnConnection"
  location                   = module.settings.default.primary_location
  resource_group_name        = azurerm_resource_group.primaryHubResourceGroup.name
  type                       = "IPsec"
  enable_bgp                 = true
  virtual_network_gateway_id = azurerm_virtual_network_gateway.primaryVpnGW.id
  local_network_gateway_id   = azurerm_local_network_gateway.primaryVpnlGW.id
  shared_key                 = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
  tags                       = module.settings.default_tags
}

resource "azurerm_virtual_network_gateway" "primaryERGW" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    module.primaryHubVnet,
    azurerm_public_ip.primaryERGW_pip01
  ]
  name                = "primary-hub-ERGW"
  location            = module.settings.default.primary_location
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name

  type     = "ExpressRoute"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "ErGw1AZ"

  ip_configuration {
    name                          = "primaryHubERGatewayIPConfig"
    public_ip_address_id          = azurerm_public_ip.primaryERGW_pip01.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = module.primaryHubVnet.subnets.GatewaySubnet.id
  }
  tags = module.settings.default_tags
}

resource "azurerm_route_server" "primaryARS" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_virtual_network_gateway.primaryVpnGW,
    azurerm_public_ip.primaryARS_pip01
  ]
  name                             = "primary-hub-ARS"
  resource_group_name              = azurerm_resource_group.primaryHubResourceGroup.name
  location                         = module.settings.default.primary_location
  sku                              = "Standard"
  public_ip_address_id             = azurerm_public_ip.primaryARS_pip01.id
  subnet_id                        = module.primaryHubVnet.subnets.RouteServerSubnet.id
  branch_to_branch_traffic_enabled = true
}

# set to conditional if asn and ip != null
resource "azurerm_route_server_bgp_connection" "primaryARS_bgpconnection01" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_route_server.primaryARS
  ]
  name            = "primary-hub-ARS-bgpconnection-01"
  route_server_id = azurerm_route_server.primaryARS.id
  peer_asn        = 65050
  peer_ip         = "169.254.21.5"
}

# deploy hub1 to hub2 peering
resource "azurerm_virtual_network_peering" "hub1TOhub2" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    module.primaryHubVnet,
    module.secondaryHubVnet
  ]
  name                      = "hub1TOhub2"
  resource_group_name       = module.primaryHubVnet.vnet_resource.resource_group_name
  virtual_network_name      = module.primaryHubVnet.vnet_resource.name
  remote_virtual_network_id = module.secondaryHubVnet.virtual_network_id
  allow_gateway_transit     = true
}

# deploy hub2 to hub1 peering
resource "azurerm_virtual_network_peering" "hub2TOhub1" {
  provider = azurerm.subscription_id_connectivity2
  depends_on = [
    module.primaryHubVnet,
    module.secondaryHubVnet,
    resource.azurerm_virtual_network_peering.hub1TOhub2
  ]
  name                      = "hub2TOhub1"
  resource_group_name       = module.secondaryHubVnet.vnet_resource.resource_group_name
  virtual_network_name      = module.secondaryHubVnet.vnet_resource.name
  remote_virtual_network_id = module.primaryHubVnet.virtual_network_id
  use_remote_gateways       = false
}