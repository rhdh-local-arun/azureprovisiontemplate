# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project_name}-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Subnet for AKS
resource "azurerm_subnet" "aks" {
  count                = var.create_aks_subnet ? 1 : 0
  name                 = "snet-aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Subnet for VMs
resource "azurerm_subnet" "vm" {
  count                = var.create_vm_subnet ? 1 : 0
  name                 = "snet-vm"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group for VMs
resource "azurerm_network_security_group" "vm" {
  count               = var.create_vm_subnet ? 1 : 0
  name                = "nsg-vm-${var.project_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Associate NSG with VM subnet
resource "azurerm_subnet_network_security_group_association" "vm" {
  count                     = var.create_vm_subnet ? 1 : 0
  subnet_id                 = azurerm_subnet.vm[0].id
  network_security_group_id = azurerm_network_security_group.vm[0].id
}
