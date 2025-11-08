terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tflab-juan"
    storage_account_name = "statetflabjuan24633"
    container_name       = "tfstate"
    key                  = "day2.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-tflab-day2"
  location = var.location
}

module "network" {
  source   = "./modules/network"
  rg_name  = azurerm_resource_group.rg.name
  location = var.location
}

module "compute" {
  source    = "./modules/compute"
  rg_name   = azurerm_resource_group.rg.name
  subnet_id = module.network.subnet_id
}

module "storage" {
  source   = "./modules/storage"
  rg_name  = azurerm_resource_group.rg.name
  location = var.location
}

output "vm_public_ip" {
  value = module.compute.public_ip
}

output "vnet_name" {
  value = module.network.vnet_name
}

