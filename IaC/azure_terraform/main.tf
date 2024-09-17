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

# create public IP for each control-plane VM
resource "azurerm_public_ip" "kubernetes_pip" {
  count               = var.control_vm_count
  name                = "k8s-pip-${count.index}"
  location            = azurerm_resource_group.kubernetes_rg.location
  resource_group_name = azurerm_resource_group.kubernetes_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create NIC for each control-plane VM: NIC connects the VM to the VNET
resource "azurerm_network_interface" "control_plane_nic" {
  count               = var.control_vm_count
  name                = "control_plane_nic-${count.index}"
  location            = azurerm_resource_group.kubernetes_rg.location
  resource_group_name = azurerm_resource_group.kubernetes_rg.name

 ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kubernetes_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.kubernetes_pip[count.index].id
  }
}

# Create pubic IP for each worker VM
resource "azurerm_public_ip" "worker_pip" {
  count               = var.worker_vm_count
  name                = "worker-pip-${count.index}"
  location            = azurerm_resource_group.kubernetes_rg.location
  resource_group_name = azurerm_resource_group.kubernetes_rg.name
  allocation_method   = "Static" # static IP allocation must be used when creating Standard SKU public IP addresses
  sku                 = "Standard"
}


# Create NIC for each worker VM: NIC connects the VM to the VNET
resource "azurerm_network_interface" "worker_node_nic" {
  count               = var.worker_vm_count
  name                = "worker_node_nic-${count.index}"
  location            = azurerm_resource_group.kubernetes_rg.location
  resource_group_name = azurerm_resource_group.kubernetes_rg.name

 ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kubernetes_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.worker_pip[count.index].id
  }
}

# Create control-plane VMs
resource "azurerm_linux_virtual_machine" "control_vm" {
  count                = var.control_vm_count
  name                 = "control-vm-${count.index}"
  resource_group_name  = azurerm_resource_group.kubernetes_rg.name
  location             = azurerm_resource_group.kubernetes_rg.location
  size                 = "Standard_B2s" # 2vCPUs, 4GB RAM
  admin_username       = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.control_plane_nic[count.index].id,
  ]

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

# Create worker node VMs
resource "azurerm_linux_virtual_machine" "worker_vm" {
  count                = var.worker_vm_count
  name                 = "worker-vm-${count.index}"
  resource_group_name  = azurerm_resource_group.kubernetes_rg.name
  location             = azurerm_resource_group.kubernetes_rg.location
  size                 = "Standard_B2s" # 2vCPUs, 4GB RAM
  admin_username       = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.worker_node_nic[count.index].id,
  ]

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

# Open SSH Port 22 and 6443
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

  security_rule {
    name                       = "K8SAPI" # Kubernetes API Server listens on port 6443
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate network security group with control-plane NICs
resource "azurerm_network_interface_security_group_association" "control_nsg_association" {
  count                      = var.control_vm_count
  network_interface_id       = azurerm_network_interface.control_plane_nic[count.index].id
  network_security_group_id  = azurerm_network_security_group.nsg.id
}

# Associate network security group with worker node NICs
resource "azurerm_network_interface_security_group_association" "worker_nsg_association" {
  count                      = var.worker_vm_count
  network_interface_id       = azurerm_network_interface.worker_node_nic[count.index].id
  network_security_group_id  = azurerm_network_security_group.nsg.id
}

# Output the public IP address of the control-plane VMs and the private IP address of the worker node VMs
output "ssh_command" {
  value = join(", ", [for ip in azurerm_public_ip.kubernetes_pip : "ssh -i .ssh/admin adminuser@${ip.ip_address}"])
}

# Generate ansible inventory file
resource "local_file" "inventory_file" {
  filename = "${path.module}/ansible_provisioning/inventory.j2"
  content = templatefile("${path.module}/inventory.j2.tpl", {
    control_ips = [for i, ip in azurerm_public_ip.kubernetes_pip : { index = i, address = ip.ip_address }]
    worker_ips  = [for i, ip in azurerm_public_ip.worker_pip : { index = i, address = ip.ip_address }]
  })
}