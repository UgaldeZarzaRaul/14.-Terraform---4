subscription_id = "00000000-0000-0000-0000-000000000000" # <-- reemplaza con: az account show --query id -o tsv
location        = "northcentralus"
project         = "lz"
environment     = "prod"

extra_tags = {
  curso    = "Terraform-4"
  alumno   = "tu-nombre"
}
