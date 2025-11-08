#variable "rg_name" {}
#variable "location" { default = "eastus" }

resource "azurerm_network_interface" "vm_nic" {
  name                = "tflab-vm-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "tflab-vm"
  resource_group_name             = var.rg_name
  location                        = var.location
  size                            = "Standard_B1s" # gratuita elegible
  admin_username                  = "azureuser"
  network_interface_ids           = [azurerm_network_interface.vm_nic.id]
  disable_password_authentication = false
  admin_password                  = "Nova2025!"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

output "vm_private_ip" {
  value = azurerm_network_interface.vm_nic.private_ip_address
}

