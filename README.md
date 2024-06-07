# terraform-ptn-hubs

Enterprise Scale LZ Connectivity Hubs Example

[Azure Route Server support for ExpressRoute and Azure VPN](https://learn.microsoft.com/en-us/azure/route-server/expressroute-vpn-support)

Conceptual diagram:


<div align="center">
  <img src="https://github.com/ptsouk/terraform-ptn-hubs/blob/main/terraform-ptn-hubs.jpg?raw=true"
  width="600" height="600"/>
</div>

## AZ CLI

```bash
az login --tenant f6279e07-c6ac-45ee-a551-12a2fdf33d14 --use-device-code

az account list

az account set --subscription 8ec43e9c-d13a-4219-a0d5-43292d705a78

az logout
```

## Terraform

```bash
terraform init

terraform plan -out main.tfplan

terraform apply main.tfplan

terraform plan -destroy -out main.destroy.tfplan

terraform apply main.destroy.tfplan

terraform apply -auto-approve

terraform destroy -auto-approve
```
