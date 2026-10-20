variable "azure_region" {
  description = "Azure region for resources"
  type        = string
  default     = "${{ values.azureRegion }}"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "${{ values.environment }}"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "${{ values.name }}"
}

{%- if values.resourceType == 'aks' or values.resourceType == 'both' %}

# AKS Variables
variable "aks_node_count" {
  description = "Number of nodes in AKS cluster"
  type        = number
  default     = ${{ values.aksNodeCount }}
}

variable "aks_node_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "${{ values.aksNodeSize }}"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "${{ values.kubernetesVersion }}"
}

variable "enable_auto_scaling" {
  description = "Enable AKS autoscaling"
  type        = bool
  default     = ${{ values.enableAutoScaling }}
}

variable "min_node_count" {
  description = "Minimum node count for autoscaling"
  type        = number
  default     = ${{ values.minNodeCount }}
}

variable "max_node_count" {
  description = "Maximum node count for autoscaling"
  type        = number
  default     = ${{ values.maxNodeCount }}
}
{%- endif %}

{%- if values.resourceType == 'vm' or values.resourceType == 'both' %}

# VM Variables
variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "${{ values.vmSize }}"
}

variable "vm_os" {
  description = "VM operating system"
  type        = string
  default     = "${{ values.vmOS }}"
}

variable "disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = ${{ values.diskSize }}
}

variable "enable_public_ip" {
  description = "Enable public IP for VM"
  type        = bool
  default     = ${{ values.enablePublicIP }}
}

variable "admin_username" {
  description = "Admin username for VM"
  type        = string
  default     = "azureadmin"
}
{%- endif %}
