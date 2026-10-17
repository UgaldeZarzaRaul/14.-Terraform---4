variable "subscription_id" {
  description = "ID de la suscripción Azure for Students."
  type        = string
}

variable "location" {
  description = "Región de Azure (Mexico Central no disponible en la cuenta, se usa North Central US)."
  type        = string
  default     = "northcentralus"
}

variable "project" {
  description = "Nombre corto del proyecto (solo minúsculas y números)."
  type        = string
  default     = "lz"
}

variable "environment" {
  description = "Ambiente."
  type        = string
  default     = "prod"
}

# ---------- Red ----------
variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_app_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "subnet_db_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "subnet_vm_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "subnet_endpoints_cidr" {
  type    = string
  default = "10.0.4.0/24"
}

variable "subnet_bastion_cidr" {
  type    = string
  default = "10.0.5.0/24"
}

variable "pe_postgres_ip" {
  description = "IP fija del Private Endpoint de PostgreSQL (dentro de snet-db)."
  type        = string
  default     = "10.0.2.4"
}

variable "pe_blob_ip" {
  description = "IP fija del Private Endpoint de Blob (dentro de snet-endpoints)."
  type        = string
  default     = "10.0.4.4"
}

# ---------- Cómputo ----------
variable "app_service_sku" {
  type    = string
  default = "B1"
}

variable "vm_size" {
  description = "Tamaño de la VM worker. Si B2ats_v2 no está disponible, probar Standard_B1s / Standard_B2s."
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

# ---------- Datos ----------
variable "postgres_sku" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "postgres_version" {
  type    = string
  default = "16"
}

variable "postgres_storage_mb" {
  type    = number
  default = 32768
}

variable "postgres_admin_login" {
  type    = string
  default = "pgadmin"
}

variable "postgres_database_name" {
  type    = string
  default = "appdb"
}

variable "enable_entra_admins" {
  description = "Registrar las Managed Identities (App y VM) como administradores Entra ID de PostgreSQL."
  type        = bool
  default     = true
}

variable "storage_public_network_access_enabled" {
  description = "false según el diagrama. Si el apply falla con 403 en el Storage, ponerlo en true, aplicar y volver a false."
  type        = bool
  default     = false
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}
