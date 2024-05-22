# provider "azurerm" {
#   features {
#     resource_group {
#       prevent_deletion_if_contains_resources = true
#     }
#   }
# }
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  alias = "subscription_id_management"
  subscription_id = module.settings.default.subscription_id_management
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  alias = "subscription_id_connectivity1"
  subscription_id = module.settings.default.subscription_id_connectivity1
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  alias = "subscription_id_connectivity2"
  subscription_id = module.settings.default.subscription_id_connectivity2
}