variable "subscription_id" {
  default = "33412aad-8988-47c9-a0ae-0c95efad1811"
  type = string
  description = "The Azure Subscription ID"
}

variable "rg_name" {
  default = "k8sdemo"
  type = string
  description = "The Name of the resource group"
}

variable "location" {
  default = "West Europe"
  type = string
  description = "The Azure Region in which all resources in this example should be provisioned"
}

variable "control_vm_count" {
  default = 2
  type = number
  description = "The number of VMs to create"
}

variable "worker_vm_count" {
  default = 1
  type = number
  description = "The number of VMs to create"
}