# Choose Your Deployment Mode

This template supports **two deployment modes**. Choose one based on your needs:

## 🚀 Mode 1: Terraform Cloud (Recommended for Demo)

**True GitOps** - Terraform Cloud watches your Git repo and automatically applies changes.

### ✅ Pros:
- No pipeline configuration needed
- Automatic runs on every push
- Beautiful UI with plan/apply history
- State management handled automatically
- Team collaboration features
- Free tier available

### ⚠️ Cons:
- Requires Terraform Cloud account
- State stored in HashiCorp's cloud

### Setup (5 minutes):

```bash
# 1. Activate Terraform Cloud backend
mv terraform/backend-cloud.tf.example terraform/backend.tf

# 2. Create Terraform Cloud account
# Visit: https://app.terraform.io/signup

# 3. Login from CLI
terraform login

# 4. Initialize
cd terraform
terraform init

# 5. In Terraform Cloud UI:
#    - Go to workspace settings
#    - Connect to Git repository (VCS)
#    - Set Azure credentials as environment variables:
#      ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID
#    - Enable auto-apply (optional)

# 6. Push to Git - Terraform Cloud automatically runs!
git push origin main
```

**That's it!** Every Git push triggers Terraform automatically.

---

## 🔧 Mode 2: CI/CD Pipelines (Traditional)

**Pipeline-based** - GitHub Actions or Azure DevOps runs Terraform.

### ✅ Pros:
- Full control over execution
- State stored in Azure (data sovereignty)
- Integrates with existing CI/CD
- No third-party dependencies

### ⚠️ Cons:
- Requires pipeline configuration
- More setup steps
- Need to maintain pipeline code

### Setup Options:

#### Option A: GitHub Actions

```bash
# 1. Activate Azure Storage backend
mv terraform/backend-azure.tf.example terraform/backend.tf

# 2. Create Azure service principal
az ad sp create-for-rbac \
  --name "${{ values.name }}-sp" \
  --role Contributor \
  --scopes /subscriptions/<subscription-id> \
  --sdk-auth

# 3. Add secrets to GitHub repository:
#    - AZURE_CREDENTIALS (full JSON from above)
#    - AZURE_SUBSCRIPTION_ID
#    - AZURE_TENANT_ID
#    - AZURE_CLIENT_ID
#    - AZURE_CLIENT_SECRET

# 4. Push to Git - GitHub Actions runs automatically
git push origin main
```

#### Option B: Azure DevOps

```bash
# 1. Activate Azure Storage backend
mv terraform/backend-azure.tf.example terraform/backend.tf

# 2. Create service connection in Azure DevOps
#    Name: "Azure-ServiceConnection"

# 3. Create pipeline from azure-pipelines.yml

# 4. Push to Git - Pipeline runs automatically
git push origin main
```

See [docs/azure-devops-setup.md](docs/azure-devops-setup.md) for detailed steps.

---

## 📊 Comparison

| Feature | Terraform Cloud | GitHub Actions | Azure DevOps |
|---------|----------------|----------------|--------------|
| **Setup Time** | 5 min | 10 min | 15 min |
| **Auto-run on push** | ✅ Native | ✅ Via workflow | ✅ Via pipeline |
| **State storage** | TF Cloud | Azure Storage | Azure Storage |
| **Cost** | Free tier | Free (public repos) | Free tier |
| **UI** | ✅ Excellent | ⚠️ Basic | ✅ Good |
| **Best for** | Quick demo, teams | GitHub users | Azure-centric orgs |
| **Plan comments** | ✅ Native | ✅ Yes | ⚠️ Needs extension |

---

## 🎯 Recommendation for Demo

**Use Terraform Cloud!**

Why?
- ✅ Fastest setup (5 minutes)
- ✅ Best visual experience for demos
- ✅ Shows true GitOps (no pipeline code)
- ✅ Professional UI impresses stakeholders
- ✅ Easy to show plan/apply history

For production, choose based on your organization's needs.

---

## Switching Between Modes

You can switch modes anytime! Your infrastructure won't be affected.

**📖 See [SWITCHING_MODES.md](SWITCHING_MODES.md) for detailed step-by-step instructions.**

### Quick Switch Commands

**To Terraform Cloud:**
```bash
mv terraform/backend.tf terraform/backend-azure.tf.backup
mv terraform/backend-cloud.tf.example terraform/backend.tf
terraform login
terraform init -migrate-state
```

**To Pipelines:**
```bash
mv terraform/backend.tf terraform/backend-cloud.tf.backup
mv terraform/backend-azure.tf.example terraform/backend.tf
terraform init -migrate-state
```

The `-migrate-state` flag safely copies your state between backends without affecting your Azure resources.

---

## Quick Start Guide

**For Demo (Terraform Cloud):**
```bash
mv terraform/backend-cloud.tf.example terraform/backend.tf
# Follow Terraform Cloud setup above
```

**For Production (Pipeline):**
```bash
mv terraform/backend-azure.tf.example terraform/backend.tf
# Follow GitHub Actions or Azure DevOps setup above
```

---

## Need Help?

- Terraform Cloud: https://developer.hashicorp.com/terraform/cloud-docs
- GitHub Actions: See `.github/workflows/terraform.yml`
- Azure DevOps: See `docs/azure-devops-setup.md`
