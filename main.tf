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
