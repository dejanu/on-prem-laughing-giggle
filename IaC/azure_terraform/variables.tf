variable "rg_name" {
  default = "sredemo"
  type = string
  description = "The Name of the resource group"
}

variable "location" {
  default = "West Europe"
  type = string
  description = "The Azure Region in which all resources in this example should be provisioned"
}