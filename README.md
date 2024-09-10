# on-prem-laughing-giggle
Stack: vagrant/terraform/k8s

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

* Azure [provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)