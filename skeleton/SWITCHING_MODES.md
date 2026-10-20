# Switching Between Deployment Modes

Simple guide to switch between Terraform Cloud and Pipeline modes.

## 🔄 Currently Using Pipelines → Switch to Terraform Cloud

### Step 1: Activate Terraform Cloud Backend

```bash
cd terraform

# Rename current backend (backup)
mv backend.tf backend-azure.tf.backup

# Activate Terraform Cloud backend
mv backend-cloud.tf.example backend.tf

# Update organization name in backend.tf
# Edit backend.tf and change "YOUR_ORG_NAME" to your Terraform Cloud org
```

### Step 2: Login to Terraform Cloud

```bash
terraform login
```

This will:
- Open your browser
- Create an API token
- Save it locally

### Step 3: Migrate State

```bash
# Re-initialize with new backend
terraform init -migrate-state
```

You'll see:
```
Do you want to copy existing state to the new backend?
```

Type `yes` - this safely moves your state from Azure Storage to Terraform Cloud.

### Step 4: Verify Migration

```bash
# Check state is in Terraform Cloud
terraform state list
```

### Step 5: Configure Terraform Cloud

In Terraform Cloud UI (https://app.terraform.io):

1. Go to your workspace
2. **Settings** → **Version Control** → Connect your Git repo
3. **Variables** → Add Azure credentials:
   - `ARM_CLIENT_ID` (sensitive)
   - `ARM_CLIENT_SECRET` (sensitive)
   - `ARM_SUBSCRIPTION_ID` (sensitive)
   - `ARM_TENANT_ID` (sensitive)

### Step 6: Test

```bash
# Make a small change
echo "# Switched to Terraform Cloud" >> main.tf

git add .
git commit -m "Switch to Terraform Cloud"
git push origin main
```

**Watch Terraform Cloud UI** - it should automatically trigger a run!

### Step 7: Optional - Remove Pipeline Files

Since you don't need them anymore:

```bash
# Optional: Remove GitHub Actions
git rm -r .github/workflows/

# Optional: Remove Azure DevOps pipeline
git rm azure-pipelines.yml

git commit -m "Remove pipeline files"
git push origin main
```

---

## 🔄 Currently Using Terraform Cloud → Switch to Pipelines

### Step 1: Choose Your Pipeline

**Option A: GitHub Actions**
**Option B: Azure DevOps**

(Instructions below use GitHub Actions, but same process for Azure DevOps)

### Step 2: Activate Azure Storage Backend

```bash
cd terraform

# Rename current backend (backup)
mv backend.tf backend-cloud.tf.backup

# Activate Azure Storage backend
mv backend-azure.tf.example backend.tf
```

### Step 3: Configure Pipeline Secrets

**For GitHub Actions:**

Add these secrets to your GitHub repository (Settings → Secrets → Actions):

```bash
# Create service principal first
az ad sp create-for-rbac \
  --name "myproject-sp" \
  --role Contributor \
  --scopes /subscriptions/<subscription-id> \
  --sdk-auth

# Add to GitHub secrets:
# - AZURE_CREDENTIALS (full JSON output)
# - AZURE_SUBSCRIPTION_ID
# - AZURE_TENANT_ID  
# - AZURE_CLIENT_ID
# - AZURE_CLIENT_SECRET
```

**For Azure DevOps:**

Create a service connection named `Azure-ServiceConnection`

### Step 4: Migrate State

```bash
# Re-initialize with new backend
terraform init -migrate-state
```

You'll see:
```
Do you want to copy existing state to the new backend?
```

Type `yes` - this safely moves your state from Terraform Cloud to Azure Storage.

**Note:** The pipeline will auto-create the Azure Storage backend if it doesn't exist!

### Step 5: Verify Migration

```bash
# Check state
terraform state list

# Verify backend is Azure Storage
cat backend.tf
```

### Step 6: Test

```bash
# Make a small change
echo "# Switched to Pipelines" >> main.tf

git add .
git commit -m "Switch to pipeline mode"
git push origin main
```

**Watch GitHub Actions/Azure DevOps** - the pipeline should trigger!

### Step 7: Optional - Disconnect Terraform Cloud

In Terraform Cloud UI:

1. Go to workspace
2. **Settings** → **Destruction and Deletion**
3. Queue destroy plan (if you want to clean up)
4. Delete workspace

---

## 📋 Quick Reference

### Current Mode: Pipelines

```bash
# File that exists
terraform/backend.tf  (contains: backend "azurerm")

# Files available
terraform/backend-cloud.tf.example

# Switch command
mv terraform/backend.tf terraform/backend-azure.tf.backup
mv terraform/backend-cloud.tf.example terraform/backend.tf
terraform init -migrate-state
```

### Current Mode: Terraform Cloud

```bash
# File that exists
terraform/backend.tf  (contains: cloud { organization })

# Files available
terraform/backend-azure.tf.example

# Switch command
mv terraform/backend.tf terraform/backend-cloud.tf.backup
mv terraform/backend-azure.tf.example terraform/backend.tf
terraform init -migrate-state
```

---

## ❓ FAQ

### Q: Will I lose my infrastructure during the switch?

**A:** No! The `-migrate-state` flag safely copies your state to the new backend. Your actual Azure resources are not touched.

### Q: What if migration fails?

**A:** Your backup is safe! Just rename it back:
```bash
mv backend-azure.tf.backup backend.tf
terraform init
```

### Q: Can I keep both backends?

**A:** No, Terraform only supports one backend at a time. But you can switch back and forth anytime.

### Q: What happens to the old state?

**A:** It stays in the old location:
- Terraform Cloud: State stays in your workspace (you can delete it)
- Azure Storage: State stays in the storage account (you can delete it)

### Q: Do I need to change anything in my Terraform code?

**A:** No! Only the backend changes. Your `main.tf`, `variables.tf`, etc. stay the same.

### Q: How long does migration take?

**A:** Usually a few seconds. Depends on state file size.

### Q: Can I test without migrating state?

**A:** Yes! Initialize a fresh workspace:
```bash
terraform init  # Don't use -migrate-state
# This creates a new empty state
# But you'll lose track of existing resources
```

**Not recommended** - better to migrate state properly.

---

## 🚨 Important Notes

1. **Always backup your backend.tf** before switching
2. **Use `-migrate-state`** to preserve your infrastructure tracking
3. **Configure credentials** in the new system before testing
4. **One backend at a time** - can't use both simultaneously
5. **State location changes** but infrastructure stays the same

---

## ✅ Verification Checklist

After switching, verify:

- [ ] `terraform state list` shows your resources
- [ ] Push to Git triggers automation (TF Cloud or Pipeline)
- [ ] Can run `terraform plan` successfully
- [ ] Backend credentials are configured
- [ ] Old state file is backed up (optional: delete it)

---

## 🆘 Troubleshooting

### "Backend configuration changed"

**Solution:** Run `terraform init -reconfigure` or `terraform init -migrate-state`

### "No stored state found"

**Problem:** State didn't migrate properly.

**Solution:** 
1. Restore backup: `mv backend-*.backup backend.tf`
2. Run `terraform init`
3. Try migration again

### "Credentials not configured"

**Terraform Cloud:** Add ARM_* variables in workspace settings

**Pipelines:** Add secrets to GitHub/Azure DevOps

### State is empty after migration

**Problem:** Migration didn't copy state.

**Solution:**
1. Check old backend still has state
2. Restore backup backend.tf
3. Download state: `terraform state pull > backup.tfstate`
4. Switch backends again
5. Import state: `terraform state push backup.tfstate`

---

## 💡 Pro Tip

Keep both `.example` files in your repo! This makes switching easy for team members:

```
terraform/
  backend.tf                      # Active backend
  backend-cloud.tf.example        # Ready to activate
  backend-azure.tf.example        # Ready to activate
```

Anyone on the team can switch modes by just renaming files!
