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
  enable_telemetry    = var.enable_telemetry
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
  enable_telemetry    = var.enable_telemetry
  resource_group_name = azurerm_resource_group.secondaryHubResourceGroup.name
  name                = module.settings.NSGRules.nsg_names.nsg02_name
  location            = module.settings.default.secondary_location
  security_rules      = module.settings.NSGRules.nsg_rules.nsg02_rules
  tags                = module.settings.default_tags
}

resource "azurerm_route_table" "udr01" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup
  ]
  resource_group_name           = azurerm_resource_group.primaryHubResourceGroup.name
  name                          = module.settings.UDRs.udr_names.udr01_name
  location                      = module.settings.default.primary_location
  disable_bgp_route_propagation = false
  tags                          = module.settings.default_tags
}

resource "azurerm_route" "udr01Route01" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup,
    azurerm_route_table.udr01
  ]
  name                = module.settings.UDRs.routes.udr01Routes.udr01Route01.name
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name
  route_table_name    = module.settings.UDRs.udr_names.udr01_name
  address_prefix      = module.settings.UDRs.routes.udr01Routes.udr01Route01.address_prefix
  next_hop_type       = module.settings.UDRs.routes.udr01Routes.udr01Route01.next_hop_type
}

resource "azurerm_route" "udr01Route02" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup,
    azurerm_route_table.udr01
  ]
  name                   = module.settings.UDRs.routes.udr01Routes.udr01Route02.name
  resource_group_name    = azurerm_resource_group.primaryHubResourceGroup.name
  route_table_name       = module.settings.UDRs.udr_names.udr01_name
  address_prefix         = module.settings.UDRs.routes.udr01Routes.udr01Route02.address_prefix
  next_hop_type          = module.settings.UDRs.routes.udr01Routes.udr01Route02.next_hop_type
  next_hop_in_ip_address = module.settings.UDRs.routes.udr01Routes.udr01Route02.next_hop_in_ip_address
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
  version             = "0.2.3"
  enable_telemetry    = var.enable_telemetry
  name                = module.settings.HubVnets.primaryHubVnet.name
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name
  location            = module.settings.default.primary_location
  subnets             = module.settings.HubVnets.primaryHubVnet.subnets
  dns_servers = {
    dns_servers = module.settings.HubVnets.primaryHubVnet.dns_servers
  }
  address_space = module.settings.HubVnets.primaryHubVnet.address_space
  tags          = module.settings.default_tags
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
  version             = "0.2.3"
  enable_telemetry    = var.enable_telemetry
  name                = module.settings.HubVnets.secondaryHubVnet.name
  resource_group_name = azurerm_resource_group.secondaryHubResourceGroup.name
  location            = module.settings.default.secondary_location
  subnets             = module.settings.HubVnets.secondaryHubVnet.subnets
  dns_servers = {
    dns_servers = module.settings.HubVnets.secondaryHubVnet.dns_servers
  }
  address_space = module.settings.HubVnets.secondaryHubVnet.address_space
  tags          = module.settings.default_tags
}

resource "azurerm_subnet_route_table_association" "subnet_route_table_association_01" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    module.primaryHubVnet,
    azurerm_route.udr01Route01,
    azurerm_route.udr01Route02
  ]
  subnet_id      = module.primaryHubVnet.subnets.subnet01.resource_id
  route_table_id = azurerm_route_table.udr01.id
}

resource "azurerm_local_network_gateway" "primaryVpnlGW" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup
  ]
  name                = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnlGW.name
  location            = module.settings.default.primary_location
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name
  gateway_address     = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnlGW.gateway_address
  address_space       = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnlGW.address_space
  bgp_settings {
    asn                 = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnlGW.bgp_settings.asn
    peer_weight         = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnlGW.bgp_settings.peer_weight
    bgp_peering_address = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnlGW.bgp_settings.bgp_peering_address
  }
  tags = module.settings.default_tags
}

module "primaryVpnGW_pip01" {
  providers = {
    azurerm = azurerm.subscription_id_connectivity1
  }
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup
  ]
  source              = "Azure/avm-res-network-publicipaddress/azurerm"
  version             = "0.1.2"
  enable_telemetry    = var.enable_telemetry
  name                = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnGW_pip01.name
  location            = module.settings.default.primary_location
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = module.settings.default_tags
}
module "primaryVpnGW_pip02" {
  providers = {
    azurerm = azurerm.subscription_id_connectivity1
  }
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup
  ]
  source              = "Azure/avm-res-network-publicipaddress/azurerm"
  version             = "0.1.2"
  enable_telemetry    = var.enable_telemetry
  name                = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnGW_pip02.name
  location            = module.settings.default.primary_location
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = module.settings.default_tags
}
module "primaryERGW_pip01" {
  providers = {
    azurerm = azurerm.subscription_id_connectivity1
  }
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup
  ]
  source              = "Azure/avm-res-network-publicipaddress/azurerm"
  version             = "0.1.2"
  enable_telemetry    = var.enable_telemetry
  name                = module.settings.HubVnets.primaryHubNetworkResources.primaryERGW_pip01.name
  location            = module.settings.default.primary_location
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = module.settings.default_tags
}
module "primaryARS_pip01" {
  providers = {
    azurerm = azurerm.subscription_id_connectivity1
  }
  depends_on = [
    azurerm_resource_group.primaryHubResourceGroup
  ]
  source              = "Azure/avm-res-network-publicipaddress/azurerm"
  version             = "0.1.2"
  enable_telemetry    = var.enable_telemetry
  name                = module.settings.HubVnets.primaryHubNetworkResources.primaryARS_pip01.name
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
    module.primaryVpnGW_pip01,
    module.primaryVpnGW_pip02
  ]
  name                = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnGW.name
  location            = module.settings.default.primary_location
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name

  type     = "Vpn"
  vpn_type = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnGW.vpn_type

  active_active = true
  enable_bgp    = true
  sku           = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnGW.sku
  generation    = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnGW.generation

  ip_configuration {
    name                          = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnGW.ip_configuration_1_name
    public_ip_address_id          = module.primaryVpnGW_pip01.public_ip_id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = module.primaryHubVnet.subnets.GatewaySubnet.resource_id
  }

  ip_configuration {
    name                          = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnGW.ip_configuration_2_name
    public_ip_address_id          = module.primaryVpnGW_pip02.public_ip_id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = module.primaryHubVnet.subnets.GatewaySubnet.resource_id
  }

  bgp_settings {
    asn         = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnGW.bgp_settings.asn
    peer_weight = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnGW.bgp_settings.peer_weight
  }
  tags = module.settings.default_tags
}

resource "azurerm_virtual_network_gateway_connection" "primaryVpnConnection" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_virtual_network_gateway.primaryVpnGW,
    azurerm_local_network_gateway.primaryVpnlGW
  ]
  name                       = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnConnection.name
  location                   = module.settings.default.primary_location
  resource_group_name        = azurerm_resource_group.primaryHubResourceGroup.name
  type                       = "IPsec"
  enable_bgp                 = true
  virtual_network_gateway_id = azurerm_virtual_network_gateway.primaryVpnGW.id
  local_network_gateway_id   = azurerm_local_network_gateway.primaryVpnlGW.id
  shared_key                 = module.settings.HubVnets.primaryHubNetworkResources.primaryVpnConnection.shared_key
  tags                       = module.settings.default_tags
}

resource "azurerm_virtual_network_gateway" "primaryERGW" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    module.primaryHubVnet,
    module.primaryERGW_pip01
  ]
  name                = module.settings.HubVnets.primaryHubNetworkResources.primaryERGW.name
  location            = module.settings.default.primary_location
  resource_group_name = azurerm_resource_group.primaryHubResourceGroup.name

  type     = "ExpressRoute"
  vpn_type = module.settings.HubVnets.primaryHubNetworkResources.primaryERGW.vpn_type

  active_active = false
  enable_bgp    = true
  sku           = module.settings.HubVnets.primaryHubNetworkResources.primaryERGW.sku

  ip_configuration {
    name                          = module.settings.HubVnets.primaryHubNetworkResources.primaryERGW.ip_configuration_1_name
    public_ip_address_id          = module.primaryERGW_pip01.public_ip_id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = module.primaryHubVnet.subnets.GatewaySubnet.resource_id
  }
  tags = module.settings.default_tags
}

resource "azurerm_route_server" "primaryARS" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_virtual_network_gateway.primaryVpnGW,
    module.primaryARS_pip01
  ]
  name                             = module.settings.HubVnets.primaryHubNetworkResources.primaryARS.name
  resource_group_name              = azurerm_resource_group.primaryHubResourceGroup.name
  location                         = module.settings.default.primary_location
  sku                              = "Standard"
  public_ip_address_id             = module.primaryARS_pip01.public_ip_id
  subnet_id                        = module.primaryHubVnet.subnets.RouteServerSubnet.resource_id
  branch_to_branch_traffic_enabled = false
}

# set to conditional if asn and ip != null
resource "azurerm_route_server_bgp_connection" "primaryARS_bgpconnection01" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    azurerm_route_server.primaryARS
  ]
  name            = module.settings.HubVnets.primaryHubNetworkResources.primaryARS_bgpconnection01.name
  route_server_id = azurerm_route_server.primaryARS.id
  peer_asn        = module.settings.HubVnets.primaryHubNetworkResources.primaryARS_bgpconnection01.peer_asn
  peer_ip         = module.settings.HubVnets.primaryHubNetworkResources.primaryARS_bgpconnection01.peer_ip
}

# deploy hub1 to hub2 peering
resource "azurerm_virtual_network_peering" "hub1TOhub2_peering" {
  provider = azurerm.subscription_id_connectivity1
  depends_on = [
    module.primaryHubVnet,
    module.secondaryHubVnet
  ]
  name                      = module.settings.HubVnets.hub1TOhub2_peering.name
  resource_group_name       = module.settings.default.primaryHubResourceGroup_name
  virtual_network_name      = module.primaryHubVnet.name
  remote_virtual_network_id = module.secondaryHubVnet.resource_id
  allow_gateway_transit     = true
}

# deploy hub2 to hub1 peering
resource "azurerm_virtual_network_peering" "hub2TOhub1_peering" {
  provider = azurerm.subscription_id_connectivity2
  depends_on = [
    module.primaryHubVnet,
    module.secondaryHubVnet,
    resource.azurerm_virtual_network_peering.hub1TOhub2_peering
  ]
  name                      = module.settings.HubVnets.hub2TOhub1_peering.name
  resource_group_name       = module.settings.default.secondaryHubResourceGroup_name
  virtual_network_name      = module.secondaryHubVnet.name
  remote_virtual_network_id = module.primaryHubVnet.resource_id
  use_remote_gateways       = false
}
