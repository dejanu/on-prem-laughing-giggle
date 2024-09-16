# on-prem-laughing-giggle: setup k8s on-prem-ish infr
Stack: terraform/ansible

* Steps:
    * Provision the infra
    * Install Kubernetes

## Local Setup:

VirtualBox and terraform

* pre-made virtual machine images list available at [Vagrant Boxes](https://portal.cloud.hashicorp.com/vagrant/discover)


* Terraform Vagrant provider (to enable the interation with Vagrant API). The provider will be downloaded and install during init stage: `terraform init`. Apparently Vagrant [provider](https://registry.terraform.io/providers/bmatcuk/vagrant/latest/docs) still needs a Vagrant file:

```json
resource "vagrant_vm" "my_vagrant_vm" {
  env = {
    # force terraform to re-run vagrant if the Vagrantfile changes
    VAGRANTFILE_HASH = md5(file("./Vagrantfile")),
  }
  get_ports = true
  # see schema for additional options
}
```

## Public Cloud Setup:

Azure and Terraform

## Public Cloud Setup:

Azure and Terraform setup


![Setup](./src/setup.png)



* Azure [provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

* Structure: ResourceGroup -> [VNet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#example-usage) -> [Subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)

* When you create a virtual machine (VM), you create a virtual network or **use an existing one**.
* A network interface (NIC) is the interconnection between a virtual machine and a virtual network. You can assign Public or Private IP addresses. Each NIC must be connected to a VNet that exists in the same Azure location and subscription as the NIC
  * Public IP addresses - Used to communicate inbound and outbound (WHITHOUT network address translation (NAT))


## Errors


```bash
 Error: static IP allocation must be used when creating Standard SKU public IP addresses
│
│   with azurerm_public_ip.kubernetes_pip[0],
│   on main.tf line 42, in resource "azurerm_public_ip" "kubernetes_pip":
│   42: resource "azurerm_public_ip" "kubernetes_pip" {
│
```
 Stock Keeping Unit (SKU): specific version or offering of a resource within Azure

## Resources:

* VNet [network overview](https://learn.microsoft.com/en-us/azure/virtual-network/network-overview)


* Azure [provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

* Structure: ResourceGroup -> [VNet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#example-usage) -> [Subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)


* When you create a virtual machine (VM), you create a virtual network or **use an existing one**.
* A network interface (NIC) is the interconnection between a virtual machine and a virtual network. You can assign Public or Private IP addresses. Each NIC must be connected to a VNet that exists in the same Azure location and subscription as the NIC
    * Public IP addresses - Used to communicate inbound and outbound (WHITHOUT network address translation (NAT))


## Errors


```bash
 Error: static IP allocation must be used when creating Standard SKU public IP addresses
│
│   with azurerm_public_ip.kubernetes_pip[0],
│   on main.tf line 42, in resource "azurerm_public_ip" "kubernetes_pip":
│   42: resource "azurerm_public_ip" "kubernetes_pip" {
│
```
 Stock Keeping Unit (SKU): specific version or offering of a resource within Azure

## Resources:

* VNet [network overview](https://learn.microsoft.com/en-us/azure/virtual-network/network-overview)



