# Azure Infrastructure Provisioner - Backstage Template

A comprehensive Backstage template for Red Hat Developer Hub (RHDH) that provisions Azure infrastructure including AKS clusters and Virtual Machines using Terraform.

## Features

- 🎯 **Multi-Resource Support:** Provision AKS clusters, Azure VMs, or both
- 🔧 **Terraform-Based:** Infrastructure as Code using Terraform
- 🚀 **Dual Deployment Modes:** 
  - **Terraform Cloud** - True GitOps, no pipelines needed
  - **CI/CD Pipelines** - GitHub Actions or Azure DevOps
- 🔐 **Secure by Default:** Key Vault integration for credential storage
- 📊 **Monitoring:** Built-in Log Analytics workspace
- 🌐 **Network Isolation:** Dedicated VNets and subnets
- ⚡ **Auto-scaling:** Optional AKS cluster auto-scaling
- 📝 **Well Documented:** Comprehensive README and documentation

## What This Template Provisions

### Azure Kubernetes Service (AKS)
- Kubernetes cluster with configurable node count and size
- Auto-scaling capabilities
- Azure CNI networking
- Azure Policy integration
- Log Analytics integration
- System-assigned managed identity

### Azure Virtual Machines
- Support for Ubuntu, RHEL, and Windows Server
- Configurable VM sizes and disk sizes
- Optional public IP assignment
- SSH key or password authentication
- Secure credential storage in Key Vault
- System-assigned managed identity

### Common Infrastructure
- Resource Group
- Virtual Network with dedicated subnets
- Network Security Groups
- Azure Key Vault (for VM credentials)
- Log Analytics Workspace

## Prerequisites

### For RHDH/Backstage
1. Red Hat Developer Hub or Backstage instance
2. Azure integration configured
3. Git provider integration (GitHub/GitLab)

### For Azure
1. Azure subscription with appropriate permissions
2. Service Principal for automated deployments
3. Azure CLI installed locally
4. Terraform 1.5.0 or higher

## Installation

### 1. Add Template to RHDH

Copy this template directory to your Backstage templates location:

```bash
# Clone or copy to your Backstage app
cp -r azureprovisiontemplate /path/to/backstage/templates/
```

### 2. Register Template

Add to your `app-config.yaml`:

```yaml
catalog:
  locations:
    - type: file
      target: ./templates/azureprovisiontemplate/template.yaml
      rules:
        - allow: [Template]
```

### 3. Configure Azure Integration

Ensure your Backstage has the Azure plugin configured:

```yaml
integrations:
  azure:
    - host: dev.azure.com
      credentials:
        - personalAccessToken: ${AZURE_TOKEN}
```

## Usage

### From Backstage UI

1. Navigate to **Create** → **Choose a template**
2. Select **Azure Infrastructure Provisioner**
3. Fill in the form:
   - **Project Information:** Name, description, owner
   - **Azure Configuration:** Region, resource type, environment
   - **AKS Configuration:** Node settings (if provisioning AKS)
   - **VM Configuration:** Size, OS, disk (if provisioning VM)
   - **Repository:** Where to store the generated code

4. Click **Create** and monitor the provisioning process

### What Happens Next

The template will:

1. ✅ Generate Terraform configuration based on your inputs
2. ✅ Create a new Git repository
3. ✅ Commit the infrastructure code
4. ✅ Configure GitHub Actions workflows
5. ✅ Set up GitHub environment for approvals
6. ✅ Register the component in Backstage catalog

### Automated Deployment

Once the repository is created:

1. **Configure Secrets:** Add Azure credentials to GitHub repository secrets
2. **Push to Main:** The GitHub Actions workflow automatically:
   - Creates Azure backend storage for Terraform state
   - Initializes Terraform
   - Plans and applies infrastructure changes
   
**No manual Terraform execution needed!** Everything is automated via GitOps.

## Template Structure

```
azureprovisiontemplate/
├── template.yaml                 # Main template definition
├── skeleton/                     # Template skeleton
│   ├── catalog-info.yaml        # Backstage catalog metadata
│   ├── README.md                # Generated project README
│   ├── azure-pipelines.yml      # Azure DevOps pipeline
│   ├── .gitignore               # Git ignore rules
│   ├── docs/                    # Documentation
│   │   └── index.md
│   └── terraform/               # Terraform modules
│       ├── main.tf              # Main configuration
│       ├── variables.tf         # Variables
│       ├── outputs.tf           # Outputs
│       ├── modules.tf           # Module instantiations
│       ├── networking/          # Networking module
│       ├── aks/                 # AKS module
│       └── vm/                  # VM module
└── README.md                    # This file
```

## Customization

### Modify Available Options

Edit `template.yaml` to add/remove:
- Azure regions
- VM sizes
- Operating systems
- Kubernetes versions

### Add New Resource Types

1. Create new Terraform module in `skeleton/terraform/`
2. Add module configuration to `modules.tf`
3. Update `template.yaml` with new parameters
4. Update outputs and README template

### Customize CI/CD

Modify `skeleton/azure-pipelines.yml` to:
- Add security scanning
- Include compliance checks
- Add custom deployment steps
- Configure approval gates

## Configuration Options

### Azure Regions
- East US, West US, Central US
- North Europe, West Europe
- UK South
- Southeast Asia, Japan East
- Australia East

### Resource Types
- **AKS Only:** Kubernetes cluster
- **VM Only:** Virtual machine
- **Both:** AKS cluster + VM

### AKS Configuration
- Node count: 1-100
- Node sizes: B2s to E4s_v3
- Kubernetes: 1.27-1.29
- Auto-scaling: Optional

### VM Configuration
- Sizes: B1s to F2s_v2
- OS: Ubuntu, RHEL, Windows Server
- Disk: 30-1024 GB
- Public IP: Optional

## Best Practices

### Security
- ✅ Use Key Vault for all credentials
- ✅ Enable Azure Policy on AKS
- ✅ Configure NSG rules appropriately
- ✅ Use private endpoints where possible
- ✅ Enable managed identities

### Cost Optimization
- ✅ Use auto-scaling for AKS
- ✅ Choose appropriate VM sizes
- ✅ Clean up unused resources
- ✅ Use Azure Cost Management

### Operations
- ✅ Enable monitoring and logging
- ✅ Set up alerts
- ✅ Configure backup policies
- ✅ Implement disaster recovery
- ✅ Document custom configurations

## Troubleshooting

### Template Issues

**Template not appearing:**
- Check catalog registration in `app-config.yaml`
- Verify file permissions
- Check Backstage logs

**Parameter validation errors:**
- Ensure all required fields are provided
- Check enum values match template definition

### Deployment Issues

**Terraform init fails:**
- Verify Azure credentials
- Check backend storage exists
- Ensure service principal has permissions

**Resource creation fails:**
- Check Azure subscription limits
- Verify naming conventions (Azure has specific rules)
- Review Terraform logs

**Pipeline fails:**
- Verify service connection in Azure DevOps
- Check environment configuration
- Review pipeline logs

## Contributing

To contribute improvements:

1. Fork or branch from main
2. Make your changes
3. Test with a real RHDH instance
4. Submit pull request

## Support

For issues or questions:
- Check the troubleshooting guide
- Review Terraform and Azure documentation
- Contact your platform team

## License

Copyright © 2026

## Acknowledgments

Built for Red Hat Developer Hub (RHDH) and compatible with Backstage.

Uses:
- Terraform Azure Provider
- Azure DevOps Tasks
- Backstage Scaffolder

---

**Version:** 1.0.0  
**Last Updated:** October 2026  
**Maintained By:** Platform Team
