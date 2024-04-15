terraform {
  backend "azurerm" {
    resource_group_name  = "topx-rg-backend-nonprod-eastus"
    storage_account_name = "topxsanonprod"
    container_name       = "terraform-tfstate"
    key                  = "workspace/terraform.tfstate"
  }
}
