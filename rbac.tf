# Acceso por RBAC (paso 3 y 5 del diagrama): las Managed Identities leen/escriben blobs
resource "azurerm_role_assignment" "app_blob" {
  scope                            = azurerm_storage_account.main.id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = azurerm_linux_web_app.app.identity[0].principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "vm_blob" {
  scope                            = azurerm_storage_account.main.id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = azurerm_linux_virtual_machine.worker.identity[0].principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
