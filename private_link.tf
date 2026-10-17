# ---------------- Zonas DNS privadas ----------------
resource "azurerm_private_dns_zone" "postgres" {
  name                = local.dns_zone_postgres
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone" "blob" {
  name                = local.dns_zone_blob
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "link-postgres-${local.base}"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "link-blob-${local.base}"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = local.tags
}

# ---------------- Private Endpoint PostgreSQL (snet-db, 10.0.2.4) ----------------
resource "azurerm_private_endpoint" "postgres" {
  name                = "pe-postgres-${local.base}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.db.id
  tags                = local.tags

  private_service_connection {
    name                           = "psc-postgres"
    private_connection_resource_id = azurerm_postgresql_flexible_server.main.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "ipconfig-postgres"
    private_ip_address = var.pe_postgres_ip
    subresource_name   = "postgresqlServer"
    member_name        = "postgresqlServer"
  }

  private_dns_zone_group {
    name                 = "dnsgroup-postgres"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgres.id]
  }

  depends_on = [azurerm_subnet_network_security_group_association.db]
}

# ---------------- Private Endpoint Blob (snet-endpoints, 10.0.4.4) ----------------
resource "azurerm_private_endpoint" "blob" {
  name                = "pe-blob-${local.base}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.endpoints.id
  tags                = local.tags

  private_service_connection {
    name                           = "psc-blob"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "ipconfig-blob"
    private_ip_address = var.pe_blob_ip
    subresource_name   = "blob"
    member_name        = "blob"
  }

  private_dns_zone_group {
    name                 = "dnsgroup-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }

  depends_on = [azurerm_subnet_network_security_group_association.endpoints]
}
