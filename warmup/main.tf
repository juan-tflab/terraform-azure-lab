terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "warmup" {
  name     = "rg-warmup-nova"
  location = "East US"
}
