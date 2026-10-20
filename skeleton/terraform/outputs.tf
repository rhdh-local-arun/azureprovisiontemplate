output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "location" {
  description = "Azure region"
  value       = azurerm_resource_group.main.location
}

{%- if values.resourceType == 'aks' or values.resourceType == 'both' %}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks[0].cluster_name
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = module.aks[0].cluster_id
}

output "aks_kube_config" {
  description = "Kubeconfig for AKS cluster"
  value       = module.aks[0].kube_config
  sensitive   = true
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = module.aks[0].cluster_fqdn
}
{%- endif %}

{%- if values.resourceType == 'vm' or values.resourceType == 'both' %}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = module.vm[0].vm_name
}

output "vm_id" {
  description = "ID of the virtual machine"
  value       = module.vm[0].vm_id
}

{%- if values.enablePublicIP %}
output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = module.vm[0].public_ip_address
}
{%- endif %}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = module.vm[0].private_ip_address
}
{%- endif %}
