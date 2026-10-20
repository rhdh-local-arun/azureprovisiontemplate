# ${{ values.name }} Documentation

## Introduction

This documentation provides detailed information about the Azure infrastructure provisioned for ${{ values.name }}.

## Quick Links

- [Getting Started](getting-started.md)
- [Architecture Overview](architecture.md)
- [Operations Guide](operations.md)
- [Troubleshooting](troubleshooting.md)

## Project Information

- **Project Name:** ${{ values.name }}
- **Owner:** ${{ values.owner }}
- **Environment:** ${{ values.environment }}
- **Azure Region:** ${{ values.azureRegion }}

## What's Provisioned

{%- if values.resourceType == 'aks' or values.resourceType == 'both' %}
✅ Azure Kubernetes Service (AKS) Cluster
{%- endif %}
{%- if values.resourceType == 'vm' or values.resourceType == 'both' %}
✅ Azure Virtual Machine
{%- endif %}
✅ Virtual Network and Subnets
✅ Network Security Groups
{%- if values.resourceType == 'vm' or values.resourceType == 'both' %}
✅ Azure Key Vault for secrets
{%- endif %}
✅ Log Analytics Workspace

## Infrastructure as Code

All infrastructure is managed using:
- **Terraform:** Version 1.5.0+
- **Azure Provider:** Version 3.80+
- **State Management:** Azure Storage Backend

## Next Steps

1. Review the [Architecture Overview](architecture.md)
2. Follow the [Getting Started Guide](getting-started.md)
3. Set up monitoring and alerts
4. Configure backup policies
