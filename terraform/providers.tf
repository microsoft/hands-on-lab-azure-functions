terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "1.15.0"
    }
  }

  backend "local" {}
  # backend "azurerm" {}
}

provider "azurerm" {
  features {}
}
