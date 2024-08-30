terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.111.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }

    azapi = {
      source = "Azure/azapi"
    }
  }

  backend "local" {}
  # backend "azurerm" {}
}

provider "azurerm" {
  features {}
}
