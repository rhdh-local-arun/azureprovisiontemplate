# GitHub Actions Workflows

This directory contains workflows for automated Terraform deployment.

## 📁 Files

### `terraform.yml` - Main Deployment Workflow

Automatically runs when:
- ✅ Push to `main` branch
- ✅ Pull request to `main` branch  
- ✅ Changes in `terraform/**` directory

**What it does:**
1. **Setup Stage** - Creates Azure backend storage (if doesn't exist)
2. **Validate Stage** - Checks Terraform format and syntax
3. **Plan Stage** - Shows what will change (on PRs)
4. **Apply Stage** - Provisions infrastructure (on push to main)

### `terraform-destroy.yml` - Destroy Infrastructure

Manually triggered workflow to destroy all resources.

**How to use:**
1. Go to Actions tab
2. Select "Terraform Destroy"
3. Click "Run workflow"
4. Type "destroy" to confirm
5. Run

## 🔧 Required Secrets

Add these to repository settings (Settings → Secrets → Actions):

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `AZURE_CREDENTIALS` | Full service principal JSON | `az ad sp create-for-rbac --sdk-auth` |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | `az account show --query id -o tsv` |
| `AZURE_TENANT_ID` | Azure tenant ID | From service principal output |
| `AZURE_CLIENT_ID` | Service principal client ID | From service principal output |
| `AZURE_CLIENT_SECRET` | Service principal secret | From service principal output |

## 📊 Workflow Status

Check workflow runs:
- Repository → Actions tab
- See history of all runs
- View logs for debugging

## 🚫 Disable GitHub Actions

If you're using Terraform Cloud instead:

```bash
# Remove workflows
git rm -r .github/workflows/
git commit -m "Remove GitHub Actions (using Terraform Cloud)"
git push origin main
```

Or just keep them - they won't run if you're using Terraform Cloud backend.

## 🔄 Re-enable After Switching from Terraform Cloud

If you switched from Terraform Cloud back to pipelines:

1. Make sure `backend.tf` uses `backend "azurerm"`
2. Configure GitHub secrets (listed above)
3. Push to main - workflows will auto-run

No need to recreate the workflow files - they're already here!

## 💡 Customization

Edit `terraform.yml` to:
- Change triggers (branches, paths)
- Add security scanning
- Modify approval requirements
- Add notifications
- Customize Terraform version

## 📖 More Info

- See [../DEPLOYMENT_MODE.md](../DEPLOYMENT_MODE.md) for choosing between Terraform Cloud and Pipelines
- See [../SWITCHING_MODES.md](../SWITCHING_MODES.md) for switching between modes
