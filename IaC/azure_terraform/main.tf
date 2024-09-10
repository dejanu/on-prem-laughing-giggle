# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Default Subscription defined in the Azure CLI
provider "azurerm" {
  # resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

# Create resource group
resource "azurerm_resource_group" "example" {
  name     = "${var.rg_name}"
  location = "${var.location}"
}