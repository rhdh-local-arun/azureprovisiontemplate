# Quick Start Guide

Choose your path based on what you want to demo.

## 🎯 I Want to Demo FAST (5 min)

**Use: Terraform Cloud**

```bash
# 1. Generate project from RHDH template
# 2. Clone the generated repo
# 3. Activate Terraform Cloud

cd terraform
mv backend-cloud.tf.example backend.tf

# 4. Update org name in backend.tf
# Change "YOUR_ORG_NAME" to your Terraform Cloud org

# 5. Login and init
terraform login
terraform init

# 6. Configure in Terraform Cloud UI
# - Add ARM_* environment variables
# - Connect Git repo
# - Enable auto-apply (optional)

# 7. Push to Git
git add .
git commit -m "Setup Terraform Cloud"
git push origin main

# ✅ Done! Terraform Cloud automatically provisions resources
```

**Watch:** https://app.terraform.io → Your workspace → See run

---

## 🔧 I Want to Demo CI/CD Pipelines (10 min)

**Use: GitHub Actions**

```bash
# 1. Generate project from RHDH template
# 2. Clone the generated repo
# 3. Activate pipeline backend

cd terraform
mv backend-azure.tf.example backend.tf

# 4. Create Azure service principal
az ad sp create-for-rbac \
  --name "myproject-sp" \
  --role Contributor \
  --scopes /subscriptions/<subscription-id> \
  --sdk-auth

# 5. Add secrets to GitHub
# Settings → Secrets → Actions → New repository secret
# Add: AZURE_CREDENTIALS, AZURE_SUBSCRIPTION_ID, 
#      AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET

# 6. Push to Git
git add .
git commit -m "Setup GitHub Actions"
git push origin main

# ✅ Done! GitHub Actions automatically provisions resources
```

**Watch:** GitHub → Actions tab → See workflow running

---

## 📊 I Want to Demo BOTH (15 min)

1. **Start with Terraform Cloud** (faster setup)
2. **Show it working** (push → auto-deploy)
3. **Switch to Pipelines** (see SWITCHING_MODES.md)
4. **Show it working** (push → auto-deploy)

This demonstrates flexibility!

---

## 🆘 I Just Want to Test Locally (2 min)

**Skip automation, run Terraform manually:**

```bash
cd terraform

# Remove backend config (use local state)
rm backend-cloud.tf.example backend-azure.tf.example

# Add Azure credentials
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
export ARM_SUBSCRIPTION_ID="..."
export ARM_TENANT_ID="..."

# Run Terraform
terraform init
terraform plan
terraform apply

# ✅ Resources created!
```

**Watch:** Azure Portal → Resource groups

---

## 📚 Full Guides

- **Compare options:** See `DEPLOYMENT_MODE.md`
- **Switch between modes:** See `SWITCHING_MODES.md`  
- **Terraform Cloud setup:** See `docs/terraform-cloud-setup.md`
- **Azure DevOps setup:** See `docs/azure-devops-setup.md`
- **Demo guide:** See `DEMO_GUIDE.md`

---

## 🎬 For Presenters

**Before your demo:**
1. Pre-configure both modes
2. Test both flows
3. Prepare Azure Portal view
4. Keep resources small (B-series VMs) to save money
5. Have destroy ready

**During demo:**
- Show `DEPLOYMENT_MODE.md` comparison
- Pick one mode and walk through
- Show Git push → auto-deployment
- Show Azure Portal with created resources
- Highlight no manual Terraform commands needed

**After demo:**
- Run destroy workflow
- Or: `terraform destroy`

Good luck! 🚀
