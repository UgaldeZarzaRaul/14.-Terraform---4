# ---------------- PostgreSQL Flexible Server (sin acceso público) ----------------
resource "random_password" "postgres" {
  length           = 24
  special          = true
  override_special = "!#%*-_"
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                = local.names.postgres
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  version             = var.postgres_version

  sku_name   = var.postgres_sku
  storage_mb = var.postgres_storage_mb

  administrator_login    = var.postgres_admin_login
  administrator_password = random_password.postgres.result

  backup_retention_days         = 7
  public_network_access_enabled = false

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = var.postgres_database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Managed Identities como administradores Entra ID (se encadenan: Azure solo admite una operación a la vez)
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "app" {
  count = var.enable_entra_admins ? 1 : 0

  server_name         = azurerm_postgresql_flexible_server.main.name
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = azurerm_linux_web_app.app.identity[0].principal_id
  principal_name      = azurerm_linux_web_app.app.name
  principal_type      = "ServicePrincipal"

  depends_on = [azurerm_postgresql_flexible_server_database.app]
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "vm" {
  count = var.enable_entra_admins ? 1 : 0

  server_name         = azurerm_postgresql_flexible_server.main.name
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = azurerm_linux_virtual_machine.worker.identity[0].principal_id
  principal_name      = azurerm_linux_virtual_machine.worker.name
  principal_type      = "ServicePrincipal"

  depends_on = [azurerm_postgresql_flexible_server_active_directory_administrator.app]
}

# ---------------- Storage Account Blob Standard LRS (sin acceso público) ----------------
resource "azurerm_storage_account" "main" {
  name                = local.names.storage
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = var.storage_public_network_access_enabled
  default_to_oauth_authentication = true

  tags = local.tags
}
