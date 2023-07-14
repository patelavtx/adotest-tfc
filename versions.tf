#  provider versions and backend

terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.2.2"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.17"

    }

    azuread = {
      source = "hashicorp/azuread"
      version = ">=2.27.0"
    }

  }
}
/*  
#  backend tfstate for pipeline setup; need to have storage account and container created prior
  backend "azurerm" {
    resource_group_name  = "atulrg-adotest"
    storage_account_name = "adotest13kvgh"
    container_name       = "adotestctr"
    key                  = "adokvgh.tfstate"
  }
}

*/

