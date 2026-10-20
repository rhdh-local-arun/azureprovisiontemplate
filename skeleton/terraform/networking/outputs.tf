output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = var.create_aks_subnet ? azurerm_subnet.aks[0].id : null
}

output "vm_subnet_id" {
  description = "ID of the VM subnet"
  value       = var.create_vm_subnet ? azurerm_subnet.vm[0].id : null
}

output "vm_nsg_id" {
  description = "ID of the VM network security group"
  value       = var.create_vm_subnet ? azurerm_network_security_group.vm[0].id : null
}
