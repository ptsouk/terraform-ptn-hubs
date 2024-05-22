output "default" {
  description = "Configuration settings for the deployment."
  value = {
    tenant_id                      = local.tenant_id
    subscription_id_management     = local.subscription_id_management
    primary_location               = local.primary_location
    secondary_location             = local.secondary_location
    subscription_id_connectivity1  = local.subscription_id_connectivity1
    primaryHubResourceGroup_name   = local.primaryHubResourceGroup_name
    subscription_id_connectivity2  = local.subscription_id_connectivity2
    secondaryHubResourceGroup_name = local.secondaryHubResourceGroup_name
  }
}

output default_tags {
  description = "Default tags."
  value = local.default_tags
}

output "HubVnets" {
  description = "Configuration settings for the network resources deployment."
  value = {
    primaryHubVnet   = local.primaryHubVnet
    secondaryHubVnet = local.secondaryHubVnet
  }
}

output "NSGRules" {
  description = "Configuration settings for the network resources deployment."
  value = {
    nsg_names = local.nsg_names
    nsg_rules = local.nsg_rules
  }
}
