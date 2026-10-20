# Public IP (conditional)
resource "azurerm_public_ip" "main" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "pip-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = "nic-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.main[0].id : null
  }

  tags = var.tags
}

# SSH Key for Linux VMs
resource "tls_private_key" "ssh" {
  count     = var.vm_os != "windows" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store SSH private key in Key Vault
resource "azurerm_key_vault_secret" "ssh_private_key" {
  count        = var.vm_os != "windows" ? 1 : 0
  name         = "ssh-private-key-${var.project_name}"
  value        = tls_private_key.ssh[0].private_key_pem
  key_vault_id = var.key_vault_id

  tags = var.tags
}

# Random password for Windows VMs
resource "random_password" "admin_password" {
  count   = var.vm_os == "windows" ? 1 : 0
  length  = 16
  special = true
}

# Store Windows password in Key Vault
resource "azurerm_key_vault_secret" "admin_password" {
  count        = var.vm_os == "windows" ? 1 : 0
  name         = "admin-password-${var.project_name}"
  value        = random_password.admin_password[0].result
  key_vault_id = var.key_vault_id

  tags = var.tags
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  count                 = var.vm_os != "windows" ? 1 : 0
  name                  = "vm-${var.project_name}-${var.environment}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.main.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh[0].public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_os == "ubuntu" ? "Canonical" : "RedHat"
    offer     = var.vm_os == "ubuntu" ? "0001-com-ubuntu-server-jammy" : "RHEL"
    sku       = var.vm_os == "ubuntu" ? "22_04-lts-gen2" : "9-lvm-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "main" {
  count                 = var.vm_os == "windows" ? 1 : 0
  name                  = "vm-${var.project_name}-${var.environment}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = random_password.admin_password[0].result
  network_interface_ids = [azurerm_network_interface.main.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.disk_size_gb
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
