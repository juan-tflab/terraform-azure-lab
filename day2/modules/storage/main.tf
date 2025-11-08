resource "random_integer" "suffix" {
  min = 100
  max = 999
}

resource "azurerm_storage_account" "stg" {
  name                     = "stglab${random_integer.suffix.result}"
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "lab"
  }
}

resource "azurerm_storage_container" "logs" {
  name                  = "logs"
  storage_account_name  = azurerm_storage_account.stg.name
  container_access_type = "private"
}

