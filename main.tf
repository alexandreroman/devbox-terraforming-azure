terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.59.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Get the main Azure resource group.
data "azurerm_resource_group" "devbox" {
  name = var.az_res_group
}

resource "azurerm_virtual_network" "devbox" {
  name                = "devbox-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.devbox.location
  resource_group_name = data.azurerm_resource_group.devbox.name
}

resource "azurerm_subnet" "devbox" {
  name                 = "default"
  resource_group_name  = data.azurerm_resource_group.devbox.name
  virtual_network_name = azurerm_virtual_network.devbox.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "devbox" {
  name                = "devbox-nic"
  location            = data.azurerm_resource_group.devbox.location
  resource_group_name = data.azurerm_resource_group.devbox.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devbox.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devbox-ip.id
  }
}

resource "azurerm_public_ip" "devbox-ip" {
  name                = "devbox-ip"
  resource_group_name = data.azurerm_resource_group.devbox.name
  location            = data.azurerm_resource_group.devbox.location
  allocation_method   = "Static"
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_network_security_group" "devbox-nsg" {
  name                = "devbox-nsg"
  resource_group_name = data.azurerm_resource_group.devbox.name
  location            = data.azurerm_resource_group.devbox.location

  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_linux_virtual_machine" "devbox" {
  name                = "devbox"
  resource_group_name = data.azurerm_resource_group.devbox.name
  location            = data.azurerm_resource_group.devbox.location
  size                = var.devbox_vm_size

  network_interface_ids = [
    azurerm_network_interface.devbox.id,
  ]

  admin_username = var.devbox_user_login
  admin_ssh_key {
    username   = var.devbox_user_login
    public_key = file(var.devbox_user_ssh_public)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.devbox_disk_size
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  connection {
    host        = self.public_ip_address
    user        = var.devbox_user_login
    type        = "ssh"
    private_key = file(var.devbox_user_ssh_private)
    timeout     = "4m"
    agent       = false
  }

  provisioner "file" {
    source      = "init-devbox.sh"
    destination = "/tmp/init-devbox.sh"
  }
  provisioner "file" {
    content = templatefile("init-devbox.env.tpl", {
      "devbox_user" = var.devbox_user_login
    })
    destination = "/tmp/init-devbox.env"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/init-devbox.sh",
      "cd /tmp && sudo bash /tmp/init-devbox.sh"
    ]
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "devbox-auto-shutdown" {
  virtual_machine_id = azurerm_linux_virtual_machine.devbox.id
  location           = data.azurerm_resource_group.devbox.location
  enabled            = var.devbox_shutdown_enabled

  daily_recurrence_time = var.devbox_shutdown_time
  timezone              = var.devbox_shutdown_timezone

  notification_settings {
    enabled = false
  }
}
