# Networking Module
module "networking" {
  source = "./networking"

  project_name        = var.project_name
  environment         = var.environment
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  {%- if values.resourceType == 'aks' or values.resourceType == 'both' %}
  create_aks_subnet   = true
  {%- endif %}
  {%- if values.resourceType == 'vm' or values.resourceType == 'both' %}
  create_vm_subnet    = true
  {%- endif %}

  tags = local.common_tags
}

{%- if values.resourceType == 'vm' or values.resourceType == 'both' %}

# Key Vault for storing VM credentials
resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.project_name}-${random_string.suffix.result}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge",
      "Recover"
    ]
  }

  tags = local.common_tags
}

data "azurerm_client_config" "current" {}
{%- endif %}

{%- if values.resourceType == 'aks' or values.resourceType == 'both' %}

# AKS Module
module "aks" {
  count  = 1
  source = "./aks"

  project_name        = var.project_name
  environment         = var.environment
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.networking.aks_subnet_id

  node_count          = var.aks_node_count
  node_size           = var.aks_node_size
  kubernetes_version  = var.kubernetes_version
  enable_auto_scaling = var.enable_auto_scaling
  min_node_count      = var.min_node_count
  max_node_count      = var.max_node_count

  tags = local.common_tags
}
{%- endif %}

{%- if values.resourceType == 'vm' or values.resourceType == 'both' %}

# VM Module
module "vm" {
  count  = 1
  source = "./vm"

  project_name        = var.project_name
  environment         = var.environment
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.networking.vm_subnet_id

  vm_size          = var.vm_size
  vm_os            = var.vm_os
  disk_size_gb     = var.disk_size_gb
  enable_public_ip = var.enable_public_ip
  admin_username   = var.admin_username
  key_vault_id     = azurerm_key_vault.main.id

  tags = local.common_tags

  depends_on = [azurerm_key_vault.main]
}
{%- endif %}
