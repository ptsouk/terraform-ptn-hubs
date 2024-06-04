locals {
  udr_names = {
    udr01_name = "udr01"
    udr02_name = "udr02"
  }
  routes = {
    udr01Routes = {
      "udr01Route01" = {
        name           = "udr01Route01"
        address_prefix = "10.1.0.0/16"
        next_hop_type  = "VnetLocal"
      }
      "udr01Route02" = {
        name           = "udr01Route02"
        address_prefix = "10.3.0.0/16"
        next_hop_type  = "VirtualAppliance"
        next_hop_in_ip_address = "1.2.3.4"
      }
    }
  }
}
