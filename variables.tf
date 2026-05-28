variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  default     = "1-341af44f-playground-sandbox"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  default     = "westus"
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
