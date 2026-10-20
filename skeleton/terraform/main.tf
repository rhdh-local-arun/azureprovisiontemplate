terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  backend "azurerm" {
    # Configure backend in backend.tfvars or via environment variables
    # resource_group_name  = "tfstate-rg"
    # storage_account_name = "tfstate"
    # container_name      = "tfstate"
    # key                 = "${{ values.name }}.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Generate random suffix for globally unique resources
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${{ values.name }}-${{ values.environment }}"
  location = var.azure_region

  tags = local.common_tags
}

locals {
  common_tags = {
    Project     = "${{ values.name }}"
    Environment = "${{ values.environment }}"
    ManagedBy   = "Terraform"
    Owner       = "${{ values.owner }}"
    CreatedBy   = "RHDH-Backstage"
  }
}
