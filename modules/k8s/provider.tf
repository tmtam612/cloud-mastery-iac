terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = ">=1.13.1"
    }
  }
}

provider "azapi" {
  enable_hcl_output_for_data_source = true
}
