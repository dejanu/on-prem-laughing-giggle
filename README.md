# on-prem-laughing-giggle
Stack: vagrant/terraform/k8s

* Steps:
    * Provision the infra
    * Install Kubernetes

## Local Setup:

VirtualBox and terraform installed on local machie:
    - pre-made virtual machine images list available at [Vagrant Boxes](https://portal.cloud.hashicorp.com/vagrant/discover)


Terraform Vagrant provider (to enable the interation with Vagrant API). The provider will be downloaded and install during init stage: `terraform init`