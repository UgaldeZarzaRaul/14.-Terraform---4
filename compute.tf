# ---------------- App Service (Linux B1) con VNet Integration ----------------
resource "azurerm_service_plan" "main" {
  name                = local.names.plan
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = local.tags
}

resource "azurerm_linux_web_app" "app" {
  name                = local.names.app
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true

  virtual_network_subnet_id = azurerm_subnet.app.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on              = true
    vnet_route_all_enabled = true
    minimum_tls_version    = "1.2"

    application_stack {
      python_version = "3.12"
    }
  }

  app_settings = {
    PGHOST              = azurerm_postgresql_flexible_server.main.fqdn
    PGDATABASE          = var.postgres_database_name
    PGUSER              = local.names.app
    STORAGE_BLOB_URL    = azurerm_storage_account.main.primary_blob_endpoint
  }

  tags = local.tags

  depends_on = [azurerm_subnet_network_security_group_association.app]
}

# ---------------- VM Linux worker (sin IP pública, acceso por Bastion) ----------------
resource "tls_private_key" "vm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "vm_private_key" {
  filename        = "${path.module}/keys/${local.names.vm}.pem"
  content         = tls_private_key.vm.private_key_pem
  file_permission = "0600"
}

resource "azurerm_network_interface" "worker" {
  name                = "nic-${local.names.vm}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "worker" {
  name                = local.names.vm
  computer_name       = "vm-worker"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username

  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.worker.id]

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = tls_private_key.vm.public_key_openssh
  }

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = local.tags

  depends_on = [azurerm_subnet_network_security_group_association.vm]
}
