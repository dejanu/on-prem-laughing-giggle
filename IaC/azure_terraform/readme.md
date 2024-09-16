## Prerequisites

* In the root of this directory create `mkdir .ssh && cd $_` and generate `admin` ssh-key for VM access e.g.: `ssh-keygen -C "adminuser@example.com"`

* This setup uses local backend - state is stored as local file on disk

## Usage

```bash
# initialize working directory
terraform init

# linting of TF files
terraform validate

# generates a speculative execution plan on disk
terraform plan --out createplan.tfplan

# apply the changes required to reach the desired state of the configuration
terraform apply "createplan.tfplan"

# proposed destroy changes without executing them
terraform plan -destroy -out destroy.tfplan
terraform apply "destroy.tfplan"

# interactive
terraform apply -destroy
```