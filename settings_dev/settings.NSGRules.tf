locals {
  nsg_names = {
    nsg01_name = "nsg01"
    nsg02_name = "nsg02"
  }
  nsg_rules = {
    nsg01_rules = {
      "rule01" = {
        name                       = "rule01"
        access                     = "Deny"
        destination_address_prefix = "*"
        destination_port_range     = "80-88"
        direction                  = "Outbound"
        priority                   = 100
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
      }
      "rule02" = {
        name                       = "rule02"
        access                     = "Allow"
        destination_address_prefix = "*"
        destination_port_ranges    = ["80", "443"]
        direction                  = "Inbound"
        priority                   = 200
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
      }
    }
    nsg02_rules = {
      "rule01" = {
        name                       = "rule01"
        access                     = "Deny"
        destination_address_prefix = "*"
        destination_port_range     = "80-88"
        direction                  = "Outbound"
        priority                   = 100
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
      }
      "rule02" = {
        name                       = "rule02"
        access                     = "Allow"
        destination_address_prefix = "*"
        destination_port_ranges    = ["80", "443"]
        direction                  = "Inbound"
        priority                   = 200
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
      }
    }
  }
}
