output "vm_id" {
  description = "VM ID"
  value       = var.vm_os == "windows" ? azurerm_windows_virtual_machine.main[0].id : azurerm_linux_virtual_machine.main[0].id
}

output "vm_name" {
  description = "VM name"
  value       = var.vm_os == "windows" ? azurerm_windows_virtual_machine.main[0].name : azurerm_linux_virtual_machine.main[0].name
}

output "public_ip_address" {
  description = "Public IP address"
  value       = var.enable_public_ip ? azurerm_public_ip.main[0].ip_address : null
}

output "private_ip_address" {
  description = "Private IP address"
  value       = azurerm_network_interface.main.private_ip_address
}

output "network_interface_id" {
  description = "Network interface ID"
  value       = azurerm_network_interface.main.id
}

output "vm_identity" {
  description = "VM managed identity"
  value       = var.vm_os == "windows" ? azurerm_windows_virtual_machine.main[0].identity : azurerm_linux_virtual_machine.main[0].identity
}
