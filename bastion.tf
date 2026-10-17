resource "azurerm_public_ip" "bastion" {
  name                = local.names.bastionip
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_bastion_host" "main" {
  name                = local.names.bastion
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Basic"
  tags                = local.tags

  ip_configuration {
    name                 = "ipconfig-bastion"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  depends_on = [azurerm_subnet_network_security_group_association.bastion]
}
