output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "subnets" {
  value = {
    app       = azurerm_subnet.app.address_prefixes[0]
    db        = azurerm_subnet.db.address_prefixes[0]
    vm        = azurerm_subnet.vm.address_prefixes[0]
    endpoints = azurerm_subnet.endpoints.address_prefixes[0]
    bastion   = azurerm_subnet.bastion.address_prefixes[0]
  }
}

output "app_service_url" {
  value = "https://${azurerm_linux_web_app.app.default_hostname}"
}

output "app_identity_principal_id" {
  value = azurerm_linux_web_app.app.identity[0].principal_id
}

output "vm_identity_principal_id" {
  value = azurerm_linux_virtual_machine.worker.identity[0].principal_id
}

output "vm_private_ip" {
  value = azurerm_network_interface.worker.private_ip_address
}

output "vm_ssh_private_key_file" {
  value = local_sensitive_file.vm_private_key.filename
}

output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.main.fqdn
}

output "postgres_private_endpoint_ip" {
  value = azurerm_private_endpoint.postgres.private_service_connection[0].private_ip_address
}

output "postgres_admin_password" {
  value     = random_password.postgres.result
  sensitive = true
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "blob_private_endpoint_ip" {
  value = azurerm_private_endpoint.blob.private_service_connection[0].private_ip_address
}

output "private_dns_zones" {
  value = [azurerm_private_dns_zone.postgres.name, azurerm_private_dns_zone.blob.name]
}

output "bastion_name" {
  value = azurerm_bastion_host.main.name
}
