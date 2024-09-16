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
  subscription_id = "${var.subscription_id}"
}

# Create resource group
resource "azurerm_resource_group" "kubernetes_rg" {
  name     = "${var.rg_name}"
  location = "${var.location}"
}

# Create a virtual network with a subnet within the resource group
resource "azurerm_virtual_network" "kubernetes_vnet" {
  name                = "k8s_vnet"
  resource_group_name = azurerm_resource_group.kubernetes_rg.name
  location            = azurerm_resource_group.kubernetes_rg.location
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "kubernetes_subnet" {
  name                 = "k8s_subnet"
  resource_group_name  = azurerm_resource_group.kubernetes_rg.name
  virtual_network_name = azurerm_virtual_network.kubernetes_vnet.name
  # subset of address_space
  address_prefixes     = ["10.0.1.0/24"]
}

# create public IP for each VM
resource "azurerm_public_ip" "kubernetes_pip" {
  count               = var.vm_count
  name                = "k8s-pip-${count.index}"
  location            = azurerm_resource_group.kubernetes_rg.location
  resource_group_name = azurerm_resource_group.kubernetes_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create NIC for each VM: NIC connects the VM to the VNET
resource "azurerm_network_interface" "kubernetes_nic" {
  count               = var.vm_count
  name                = "k8s_nic-${count.index}"
  location            = azurerm_resource_group.kubernetes_rg.location
  resource_group_name = azurerm_resource_group.kubernetes_rg.name

 ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kubernetes_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.kubernetes_pip[count.index].id
  }
}

# Create VMs
resource "azurerm_linux_virtual_machine" "kubernetes_vm" {
  count                = var.vm_count
  name                 = "k8s-vm-${count.index}"
  resource_group_name  = azurerm_resource_group.kubernetes_rg.name
  location             = azurerm_resource_group.kubernetes_rg.location
  size                 = "Standard_B2s" # 2vCPUs, 4GB RAM
  admin_username       = "adminuser"
  network_interface_ids = [element(azurerm_network_interface.kubernetes_nic[*].id, count.index)]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("${path.module}/.ssh/admin.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Open SSH Port 22
resource "azurerm_network_security_group" "nsg" {
  name                = "myNSG"
  location            = azurerm_resource_group.kubernetes_rg.location
  resource_group_name = azurerm_resource_group.kubernetes_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  count                      = var.vm_count
  network_interface_id       = azurerm_network_interface.kubernetes_nic[count.index].id
  network_security_group_id  = azurerm_network_security_group.nsg.id
}
# Output the IP addresses of the VMs to a file
output "ip_addresses" {
  value = {
    private = [for nic in azurerm_network_interface.kubernetes_nic : nic.private_ip_address]
    public  = [for pip in azurerm_public_ip.kubernetes_pip : pip.ip_address]
  }
}

# Render the Jinja template
data "template_file" "jinja_template" {
  template = file("${path.module}/template.j2")
  vars = {
    private_ips = output.ip_addresses.private
    public_ips = output.ip_addresses.public
  }
}

# Write the rendered template to a file
resource "local_file" "rendered_template_file" {
  filename = "/path/to/rendered_template.txt"
  content  = data.template_file.jinja_template.rendered
}
