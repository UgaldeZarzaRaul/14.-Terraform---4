locals {
  suffix = random_string.suffix.result
  base   = "${var.project}-${var.environment}"

  names = {
    rg        = "rg-${local.base}"
    vnet      = "vnet-${local.base}"
    plan      = "asp-${local.base}"
    app       = "app-${local.base}-${local.suffix}"
    postgres  = "psql-${local.base}-${local.suffix}"
    storage   = "st${var.project}${var.environment}${local.suffix}"
    vm        = "vm-${local.base}-worker"
    bastion   = "bas-${local.base}"
    bastionip = "pip-bas-${local.base}"
  }

  # Zonas DNS privadas (enlazadas a la VNet)
  dns_zone_postgres = "privatelink.postgres.database.azure.com"
  dns_zone_blob     = "privatelink.blob.core.windows.net"

  tags = merge(
    {
      proyecto    = var.project
      ambiente    = var.environment
      arquitectura = "landing-zone-well-architected"
      gestionado  = "terraform"
    },
    var.extra_tags
  )
}
