# Setup Azure Credentials

Your repository needs Azure credentials to automatically deploy infrastructure via GitHub Actions or Terraform Cloud.

## 🎯 Quick Setup (5 minutes)

### Step 1: Create Azure Service Principal

```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "<your-subscription-id>"

# Create service principal with Contributor role
az ad sp create-for-rbac \
  --name "${{ values.name }}-github-sp" \
  --role Contributor \
  --scopes /subscriptions/<your-subscription-id> \
  --sdk-auth
```

**Save the entire JSON output!** It looks like this:

```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### Step 2: Add Secrets to GitHub Repository

#### For GitHub Actions:

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these 5 secrets:

| Secret Name | Value | Where to Get It |
|-------------|-------|-----------------|
| `AZURE_CREDENTIALS` | Entire JSON output from Step 1 | Copy all JSON |
| `AZURE_SUBSCRIPTION_ID` | Subscription ID | From JSON: `subscriptionId` |
| `AZURE_TENANT_ID` | Tenant ID | From JSON: `tenantId` |
| `AZURE_CLIENT_ID` | Client ID | From JSON: `clientId` |
| `AZURE_CLIENT_SECRET` | Client Secret | From JSON: `clientSecret` |

**Screenshot of where to add:**
```
Repository → Settings → Secrets and variables → Actions → New repository secret
```

#### For Terraform Cloud:

If using Terraform Cloud backend:

1. Go to https://app.terraform.io
2. Navigate to your workspace: `${{ values.name }}-${{ values.environment }}`
3. Go to **Variables**
4. Add **Environment Variables** (mark as sensitive):

| Variable Name | Value | Sensitive |
|---------------|-------|-----------|
| `ARM_CLIENT_ID` | From JSON: `clientId` | ✅ Yes |
| `ARM_CLIENT_SECRET` | From JSON: `clientSecret` | ✅ Yes |
| `ARM_SUBSCRIPTION_ID` | From JSON: `subscriptionId` | ✅ Yes |
| `ARM_TENANT_ID` | From JSON: `tenantId` | ✅ Yes |

### Step 3: Verify Setup

#### Test GitHub Actions:

```bash
# Make a small change
echo "# Test" >> README.md
git add .
git commit -m "Test GitHub Actions"
git push origin main
```

Then:
1. Go to **Actions** tab in GitHub
2. Watch the workflow run
3. If it fails with "authentication error" → secrets not configured correctly

#### Test Terraform Cloud:

Push to Git and watch the run in Terraform Cloud UI.

## 🔐 Security Best Practices

### Rotate Credentials Regularly

Service principal secrets should be rotated:

```bash
# Create new credentials for existing service principal
az ad sp credential reset --id <client-id>
```

Then update the secrets in GitHub/Terraform Cloud.

### Use Least Privilege

Instead of `Contributor` on entire subscription, scope to specific resource groups:

```bash
# Create resource group first
az group create --name rg-${{ values.name }}-${{ values.environment }} --location ${{ values.azureRegion }}

# Create scoped service principal
az ad sp create-for-rbac \
  --name "${{ values.name }}-github-sp" \
  --role Contributor \
  --scopes /subscriptions/<subscription-id>/resourceGroups/rg-${{ values.name }}-${{ values.environment }} \
  --sdk-auth
```

### Separate Service Principals Per Environment

For production, use different service principals:

```bash
# Development
az ad sp create-for-rbac --name "${{ values.name }}-dev-sp" ...

# Staging  
az ad sp create-for-rbac --name "${{ values.name }}-staging-sp" ...

# Production
az ad sp create-for-rbac --name "${{ values.name }}-prod-sp" ...
```

Then use GitHub Environments to set different secrets per environment.

## 🆘 Troubleshooting

### Error: "Insufficient privileges to complete the operation"

**Problem:** Your user doesn't have permission to create service principals.

**Solution:** Ask your Azure admin to:
1. Grant you "Application Administrator" role in Azure AD
2. Or create the service principal for you

### Error: "The subscription is not registered to use namespace"

**Problem:** Required Azure resource providers not registered.

**Solution:**

```bash
az provider register --namespace Microsoft.ContainerService  # For AKS
az provider register --namespace Microsoft.Compute           # For VMs
az provider register --namespace Microsoft.Network           # For networking
```

### Workflow fails with "401 Unauthorized"

**Problem:** Secrets not added or incorrect format.

**Solution:**
1. Verify all 5 secrets are added in GitHub
2. Check for typos in secret names (case-sensitive!)
3. Ensure `AZURE_CREDENTIALS` is valid JSON
4. Re-create service principal if needed

### Service principal can't create resources

**Problem:** Insufficient permissions.

**Solution:**

```bash
# Verify role assignment
az role assignment list --assignee <client-id>

# Should show Contributor role
# If not, add it:
az role assignment create \
  --assignee <client-id> \
  --role Contributor \
  --scope /subscriptions/<subscription-id>
```

## 📋 Quick Reference

### Required Secrets

**For GitHub Actions:**
- `AZURE_CREDENTIALS` (JSON)
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`

**For Terraform Cloud:**
- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

### Create Service Principal Command

```bash
az ad sp create-for-rbac \
  --name "${{ values.name }}-sp" \
  --role Contributor \
  --scopes /subscriptions/<subscription-id> \
  --sdk-auth
```

### Add Secret to GitHub

```
Repository → Settings → Secrets → Actions → New repository secret
```

### Verify Secrets in GitHub Actions

Check workflow run logs:
```
Actions → Latest run → Setup job → Check environment
```

## ✅ Verification Checklist

After setup, verify:

- [ ] Service principal created
- [ ] JSON output saved securely
- [ ] All 5 secrets added to GitHub (or 4 to Terraform Cloud)
- [ ] Secret names match exactly (case-sensitive)
- [ ] Push to main triggers workflow
- [ ] Workflow authenticates successfully
- [ ] Resources can be created in Azure

If all checks pass, you're ready to deploy! 🚀

## 🔗 Additional Resources

- [Azure Service Principals](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Terraform Cloud Variables](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables)
- [Azure RBAC](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview)
