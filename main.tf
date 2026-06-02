resource "azurerm_resource_group" "rg" {
  location   = var.location
  name       = var.resource_group_name
}

resource "azurerm_virtual_network" "az-fw-vnet" {
  address_space                  = ["10.0.0.0/16"]
  location                       = azurerm_resource_group.rg.location
  name                           = var.azure_firewall_vnet_name
  resource_group_name            = azurerm_resource_group.rg.name

  subnet {
    address_prefixes               = ["10.0.1.0/26"]
    name                           = "AzureFirewallSubnet"
  }

  subnet {
    address_prefixes               = ["10.0.2.0/26"]
    name                           = "AzureFirewallManagementSubnet"
  }
}

resource "azurerm_public_ip" "az-fw-pip" {
  allocation_method       = "Static"
  location                = azurerm_resource_group.rg.location
  name                    = "test-pip"
  resource_group_name     = azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "az-fw-mngmt-pip" {
  allocation_method       = "Static"
  location                = azurerm_resource_group.rg.location
  name                    = "test-mngmt-pip"
  resource_group_name     = azurerm_resource_group.rg.name
}

resource "azurerm_firewall_policy" "az-fw-pc" {
  location                          = azurerm_resource_group.rg.location
  name                              = var.azure_firewall_policy_name
  resource_group_name               = azurerm_resource_group.rg.name
  sku                               = "Basic"
}

locals {
  subnet_ids = { for sn in azurerm_virtual_network.az-fw-vnet.subnet : sn.name => sn.id }
}

resource "azurerm_firewall" "az-fw" {
  firewall_policy_id  = azurerm_firewall_policy.az-fw-pc.id
  location            = azurerm_resource_group.rg.location
  name                = var.azure_firewall_name
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Basic"

  ip_configuration {
    name                 = "test-pip"
    public_ip_address_id = azurerm_public_ip.az-fw-pip.id
    subnet_id            = local.subnet_ids["AzureFirewallSubnet"]
  }

  management_ip_configuration {
    name                 = "test-mngmt-pip"
    public_ip_address_id = azurerm_public_ip.az-fw-mngmt-pip.id
    subnet_id            = local.subnet_ids["AzureFirewallManagementSubnet"]
  }
}

resource "azurerm_network_security_group" "spk-vnet-nsg" {
  name                = var.spoke_vnet_nsg_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  # security_rule {
  #   name                       = "AllowSSH"
  #   priority                   = 1001
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "22"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }
}

resource "azurerm_virtual_network" "spk-vnet" {
  name                = var.spoke_vnet_name
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  subnet {
      name               = "internal"
      address_prefixes   = ["10.1.3.0/24"]
      security_group     = azurerm_network_security_group.spk-vnet-nsg.id
      default_outbound_access_enabled = false
  }
}

locals {
  spoke_subnet_ids = { for sn in azurerm_virtual_network.spk-vnet.subnet : sn.name => sn.id }
}

resource "azurerm_network_interface" "vm1_nic" {
  name                = var.vm1_nic_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.spoke_subnet_ids["internal"]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                = var.vm1_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s" # Cost-effective for testing
  admin_username      = "cloud_user"
  
  network_interface_ids = [azurerm_network_interface.vm1_nic.id]

  admin_ssh_key {
    username   = "cloud_user"
    public_key = file("~/.ssh/id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
