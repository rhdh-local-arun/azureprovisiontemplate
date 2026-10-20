# ${{ values.name }}

${{ values.description }}

## Overview

This infrastructure project was generated using Red Hat Developer Hub (RHDH) Backstage template for Azure resource provisioning.

**Project Details:**
- **Owner:** ${{ values.owner }}
- **Environment:** ${{ values.environment }}
- **Azure Region:** ${{ values.azureRegion }}
- **Resource Type:** ${{ values.resourceType }}

## Resources Provisioned

{%- if values.resourceType == 'aks' or values.resourceType == 'both' %}

### Azure Kubernetes Service (AKS)
- **Cluster Name:** `aks-${{ values.name }}-${{ values.environment }}`
- **Node Count:** ${{ values.aksNodeCount }}
- **Node Size:** ${{ values.aksNodeSize }}
- **Kubernetes Version:** ${{ values.kubernetesVersion }}
- **Auto Scaling:** ${{ values.enableAutoScaling }}
{%- if values.enableAutoScaling %}
- **Min Nodes:** ${{ values.minNodeCount }}
- **Max Nodes:** ${{ values.maxNodeCount }}
{%- endif %}
{%- endif %}

{%- if values.resourceType == 'vm' or values.resourceType == 'both' %}

### Azure Virtual Machine
- **VM Name:** `vm-${{ values.name }}-${{ values.environment }}`
- **VM Size:** ${{ values.vmSize }}
- **Operating System:** ${{ values.vmOS }}
- **Disk Size:** ${{ values.diskSize }} GB
- **Public IP:** ${{ values.enablePublicIP }}
{%- endif %}

### Common Infrastructure
- **Resource Group:** `rg-${{ values.name }}-${{ values.environment }}`
- **Virtual Network:** `vnet-${{ values.name }}-${{ values.environment }}`
- **Network Security Groups:** Configured for secure access
{%- if values.resourceType == 'vm' or values.resourceType == 'both' %}
- **Key Vault:** For secure credential storage
{%- endif %}

## Prerequisites

1. **Azure Subscription** - With appropriate permissions
2. **Service Principal** - For automated deployments
3. **Git Repository** - GitHub, GitLab, or Azure DevOps
4. **CI/CD Pipeline** - GitHub Actions or Azure DevOps (pre-configured)

## Getting Started

This project supports **two deployment modes**:

1. **🚀 Terraform Cloud** - True GitOps, no pipelines needed (Recommended for demos)
2. **🔧 CI/CD Pipelines** - GitHub Actions or Azure DevOps (Traditional approach)

📖 **See [DEPLOYMENT_MODE.md](DEPLOYMENT_MODE.md) for detailed comparison and setup guide**

### Quick Start

**For Terraform Cloud (Fastest):**
```bash
mv terraform/backend-cloud.tf.example terraform/backend.tf
# Follow steps in DEPLOYMENT_MODE.md
```

**For Pipelines:**
```bash
mv terraform/backend-azure.tf.example terraform/backend.tf
# Configure GitHub secrets or Azure DevOps service connection
```

### 1. Setup Azure Service Principal

Create a service principal for the pipeline:

```bash
az ad sp create-for-rbac \
  --name "${{ values.name }}-sp" \
  --role Contributor \
  --scopes /subscriptions/<subscription-id> \
  --sdk-auth
```

Save the JSON output - you'll need it for secrets.

### 2. Configure Repository Secrets

**For GitHub Actions:**

Add these secrets to your repository (Settings → Secrets → Actions):

```
AZURE_CREDENTIALS=<full JSON output from above>
AZURE_SUBSCRIPTION_ID=<your-subscription-id>
AZURE_TENANT_ID=<your-tenant-id>
AZURE_CLIENT_ID=<client-id-from-json>
AZURE_CLIENT_SECRET=<client-secret-from-json>
```

**For Azure DevOps:**

Create a service connection named `Azure-ServiceConnection` using the service principal.

### 3. Deploy Infrastructure

Simply push to the main branch:

```bash
git add .
git commit -m "Initial infrastructure setup"
git push origin main
```

The pipeline will automatically:
- ✅ Create Azure backend storage for Terraform state
- ✅ Initialize Terraform
- ✅ Validate configuration
- ✅ Plan changes
- ✅ Apply infrastructure

### 4. Monitor Deployment

**GitHub Actions:** Check the "Actions" tab
**Azure DevOps:** Check the "Pipelines" section

Deployment typically takes 10-15 minutes.

## Accessing Resources

{%- if values.resourceType == 'aks' or values.resourceType == 'both' %}

### Connect to AKS Cluster

```bash
# Get cluster credentials
az aks get-credentials \
  --resource-group rg-${{ values.name }}-${{ values.environment }} \
  --name aks-${{ values.name }}-${{ values.environment }}

# Verify connection
kubectl get nodes
```
{%- endif %}

{%- if values.resourceType == 'vm' or values.resourceType == 'both' %}

### Connect to Virtual Machine

{%- if values.vmOS == 'windows' %}

**Windows VM (RDP):**

1. Get the admin password from Key Vault:
```bash
az keyvault secret show \
  --vault-name kv-${{ values.name }}-* \
  --name admin-password-${{ values.name }} \
  --query value -o tsv
```

2. Connect using Remote Desktop:
   - Username: `azureadmin`
   - Password: (from Key Vault)
{%- else %}

**Linux VM (SSH):**

1. Get the SSH private key from Key Vault:
```bash
az keyvault secret show \
  --vault-name kv-${{ values.name }}-* \
  --name ssh-private-key-${{ values.name }} \
  --query value -o tsv > vm-key.pem

chmod 600 vm-key.pem
```

2. Connect via SSH:
```bash
# Get public IP
PUBLIC_IP=$(terraform output -raw vm_public_ip)

# Connect
ssh -i vm-key.pem azureadmin@$PUBLIC_IP
```
{%- endif %}
{%- endif %}

## CI/CD Options

This project includes **two CI/CD options** - choose one:

### Option A: GitHub Actions (Recommended)
**Fully Automated** - Works immediately after configuring secrets.

Workflows:
- `.github/workflows/terraform.yml` - Main deployment
- `.github/workflows/terraform-destroy.yml` - Destroy resources

See "Getting Started" section above for setup.

### Option B: Azure DevOps Pipeline
**Requires Azure DevOps setup** - Good for Azure-centric organizations.

Pipeline: `azure-pipelines.yml`

The pipeline automatically:
1. **Creates backend storage** (if not exists)
2. **Validates** Terraform configuration
3. **Plans** infrastructure changes
4. **Applies** changes on merge to main

**Setup Required:**
1. Create service connection named `Azure-ServiceConnection`
2. Create pipeline from `azure-pipelines.yml`
3. (Optional) Set up environment `${{ values.environment }}` for approvals

📖 **Detailed setup:** See [docs/azure-devops-setup.md](docs/azure-devops-setup.md)

## Project Structure

```
.
├── terraform/
│   ├── main.tf              # Main Terraform configuration
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   ├── modules.tf           # Module instantiations
│   ├── networking/          # Networking module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
{%- if values.resourceType == 'aks' or values.resourceType == 'both' %}
│   ├── aks/                 # AKS module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
{%- endif %}
{%- if values.resourceType == 'vm' or values.resourceType == 'both' %}
│   └── vm/                  # VM module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
{%- endif %}
├── azure-pipelines.yml      # Azure DevOps pipeline
├── catalog-info.yaml        # Backstage catalog metadata
└── README.md               # This file
```

## Terraform Outputs

After deployment, you can view outputs:

```bash
terraform output
```

Key outputs include:
- Resource group name and ID
{%- if values.resourceType == 'aks' or values.resourceType == 'both' %}
- AKS cluster name and connection details
{%- endif %}
{%- if values.resourceType == 'vm' or values.resourceType == 'both' %}
- VM name and IP addresses
{%- endif %}

## Cost Considerations

{%- if values.resourceType == 'aks' or values.resourceType == 'both' %}
- **AKS:** Charges apply for VM nodes (${{ values.aksNodeSize }})
{%- endif %}
{%- if values.resourceType == 'vm' or values.resourceType == 'both' %}
- **VM:** Charges for compute (${{ values.vmSize }}) and storage
{%- endif %}
- **Networking:** Minimal charges for VNet and NSGs
- **Storage:** State file storage costs are minimal

For cost estimates, use the [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/).

## Making Changes

To modify infrastructure:

1. Edit Terraform files in `terraform/` directory
2. Create a pull request
3. Review the Terraform plan in PR comments
4. Merge to `main` to apply changes

## Cleanup

To destroy all resources, use the GitHub Actions workflow:

**Option 1: Manual Trigger**
1. Go to Actions → Terraform Destroy
2. Run workflow manually

**Option 2: Terraform CLI** (if needed)
```bash
cd terraform
terraform init  # if not already initialized
terraform destroy
```

**Warning:** This will permanently delete all resources!

## Support

For issues or questions:
- Create an issue in this repository
- Contact: ${{ values.owner }}

## License

Copyright © 2026
