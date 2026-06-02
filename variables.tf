variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  default     = "1-cf12a91a-playground-sandbox"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  default     = "eastus"
  type        = string
}

variable "azure_firewall_name" {
  description = "Name of the Azure Firewall"
  default     = "test-az-fw"
  type        = string
}

variable "azure_firewall_policy_name" {
  description = "Name of the Azure Firewall Policy"
  default     = "test-az-fw-policy"
  type        = string
}

variable "azure_firewall_vnet_name" {
   description = "Name of the Azure Firewall Vnet"
   default     = "test-az-fw-vnet"
   type        = string
}

variable "spoke_vnet_name" {
   description = "Name of the Spoke Vnet"
   default     = "test-spk-vnet"
   type        = string
}

variable "spoke_vnet_nsg_name" {
   description = "Name of the Spoke Vnet NSG"
   default     = "test-spk-vnet-nsg"
   type        = string
}

variable "vm1_name" {
   description = "Name of test vm1"
   default     = "vm1"
   type        = string
}

variable "vm1_nic_name" {
   description = "Name of the nic for test vm1"
   default     = "vm1-nic"
   type        = string
}

# variable "vm1_ssh_public_key" {
#    description = "SSH public key value for test vm1"
#    type        = string
#    sensitive   = true
# }