locals {
  keyvault_name          = "mySecrets762024"
  keyvault_resourceGroup = "tfstate-rg"
  secrets = {
    localadminPasswordSecretName               = "avm-localadminPassword"
    primaryVpnConnection_shared_key_SecretName = "primaryVpnConnectionSharedKey"
  }
}
