## Prerequisites

* In the root of this directory create `mkdir .ssh && cd $_` and generate `admin` ssh-key for VM access e.g.: `ssh-keygen -C "adminuser@example.com"`

* This setup uses local backend state is stored as local file on disk

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

## Remote state

* Local state not suitable in a collaborative environment therefore => move the state from local to remote backend [Azure Storage](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli)

1) Create Azure SA and a blob container. Access keys authenticate your applications requests to this storage account. (SA/Security+Networking/Access Key)
Terraform authenticates to the Azure storage account using an [Access Key by default](https://developer.hashicorp.com/terraform/language/backend/azurerm).

```bash
# create a storage account in an exiting resource group

RESOURCE_GROUP_NAME=RESOURCE_GROUP_NAME
STORAGE_ACCOUNT_NAME=SA_NAME$RANDOM #SA requires a globally unique name 
CONTAINER_NAME=CONTAINER_NAME

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

# A SA auto-generate an access key, TF can use that key to autheticate to the Azure SA
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)

# the key is not a cryptographic key ;) is more like a password
export ARM_ACCESS_KEY=$ACCOUNT_KEY
```

* Migrate backend:

```bash
terraform init will migrate the local state to the Azure Storage backend
Initializing the backend...

Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.
```