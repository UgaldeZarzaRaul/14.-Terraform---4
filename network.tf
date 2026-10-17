resource "azurerm_virtual_network" "main" {
  name                = local.names.vnet
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.vnet_cidr]
  tags                = local.tags
}

# snet-app: delegada a Microsoft.Web/serverFarms (VNet Integration del App Service)
resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_app_cidr]

  delegation {
    name = "delegation-web-serverfarms"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# snet-db: aloja el Private Endpoint de PostgreSQL
resource "azurerm_subnet" "db" {
  name                              = "snet-db"
  resource_group_name               = azurerm_resource_group.main.name
  virtual_network_name              = azurerm_virtual_network.main.name
  address_prefixes                  = [var.subnet_db_cidr]
  private_endpoint_network_policies = "Enabled"
}

# snet-vm: VM worker
resource "azurerm_subnet" "vm" {
  name                 = "snet-vm"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_vm_cidr]
}

# snet-endpoints: aloja el Private Endpoint de Blob
resource "azurerm_subnet" "endpoints" {
  name                              = "snet-endpoints"
  resource_group_name               = azurerm_resource_group.main.name
  virtual_network_name              = azurerm_virtual_network.main.name
  address_prefixes                  = [var.subnet_endpoints_cidr]
  private_endpoint_network_policies = "Enabled"
}

# El nombre debe ser exactamente AzureBastionSubnet
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_bastion_cidr]
}
