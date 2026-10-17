# Laboratorio Terraform 4 – Arquitectura de referencia Azure for Students

Landing Zone en `northcentralus`: VNet con 5 subnets + NSG, App Service (VNet Integration),
PostgreSQL Flexible Server y Storage Blob con Private Endpoints + Private DNS, VM worker y Azure Bastion.
Autenticación por Managed Identity (Entra ID / RBAC).

## Estructura
| Archivo | Contenido |
|---|---|
| terraform.tf / providers.tf | Versiones y provider azurerm |
| variables.tf / terraform.tfvars | Variables y valores |
| locals.tf | Nombres, tags, zonas DNS |
| main.tf | RG, sufijo aleatorio |
| network.tf / security.tf | VNet, subnets, NSG |
| data.tf | PostgreSQL y Storage |
| private_link.tf | Private Endpoints + DNS privado |
| compute.tf / bastion.tf | App Service, VM, Bastion |
| rbac.tf | Roles de las Managed Identities |
| outputs.tf | Salidas |

## Uso
```bash
az login
az account show --query id -o tsv      # pegar en terraform.tfvars
az provider register -n Microsoft.DBforPostgreSQL   # si no está registrado
terraform init
terraform fmt && terraform validate
terraform plan -out tfplan
terraform apply tfplan
terraform output
terraform destroy                       # al terminar (Bastion cobra por hora)
```

## Probar
- Portal -> VM -> Connect -> Bastion -> SSH Private Key from Local File -> `keys/vm-lz-prod-worker.pem`.
- Dentro de la VM: `nslookup <postgres_fqdn>` debe resolver a 10.0.2.4 y `<storage>.blob.core.windows.net` a 10.0.4.4.
