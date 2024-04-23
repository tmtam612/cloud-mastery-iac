### Setup AZ client and brew
```shell
# Install the brew.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Test that your installation was successful
brew -v

# Install Azure Cli
https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli

# Login Azure
az login

az account set --subscription <subscription-id>

```

### Install Terraform client
```shell
#First, install the HashiCorp tap, a repository of all our Homebrew packages.
brew tap hashicorp/tap

#Now, install Terraform with hashicorp/tap/terraform.
brew install hashicorp/tap/terraform

#To update to the latest version of Terraform, first update Homebrew.
brew update

#Then, run the upgrade command to download and use the latest Terraform version.
brew upgrade hashicorp/tap/terraform

# Verify Terraform installed
terraform -help
```

### Execute terraform commands
```shell
terraform init
terraform validate
terraform plan -var-file=./environment/dev.tfvars
terraform apply -var-file=./environment/dev.tfvars -auto-approve
```

### Clean-up
```shell
# Destroy all resources
terraform destroy -var-file=./environment/dev.tfvars -auto-approve
terraform apply -destroy -var-file=./environment/dev.tfvars -auto-approve

# Delete all state files
rm -rf .terraform* & rm -rf terraform.tfstate*
```

### Terraform LifeCycle
```shell
terraform init -> terraform validate -> terraform plan -> terraform apply -> terraform destroy
```

### Installing the Action Runner Controller
creating GitHub personal access token (PAT) for using by self-hosted runner make sure the following scopes are selected:

repo (all)
admin:org (all) (mandatory for organization-wide runner)
admin:public_key - read:public_key
admin:repo_hook - read:repo_hook
admin:org_hook
notifications
workflow
Also, when creating a PAT for self-hosted runner which will process events from several repositories of the particular organization, create the PAT using organization owner account. Otherwise your new PAT will not have sufficient privileges for all repositories.

