# Demo Guide: Azure Infrastructure Provisioner

Quick reference for demoing both deployment approaches.

## 🚀 Demo 1: Terraform Cloud (5 minutes)

**Show: "True GitOps - No Pipelines!"**

### Setup (Before Demo)
```bash
# Clone generated repo
git clone <repo-url>
cd <repo-name>

# Activate Terraform Cloud
mv terraform/backend-cloud.tf.example terraform/backend.tf

# Login and init
terraform login
cd terraform && terraform init
```

### Demo Flow

1. **Show DEPLOYMENT_MODE.md**
   - Explain two modes
   - Highlight Terraform Cloud benefits

2. **Show Terraform Cloud UI**
   - Open workspace in browser
   - Show clean slate

3. **Make a change**
   ```bash
   # Add a tag to main.tf
   git add . && git commit -m "Add demo tag"
   git push origin main
   ```

4. **Switch to Terraform Cloud UI**
   - Show run automatically started
   - Show plan output
   - Click "Confirm & Apply"
   - Show resources being created

5. **Show Azure Portal**
   - Resources appearing in real-time
   - Show resource group, AKS/VM

**Key Points:**
- "No pipeline code needed!"
- "Terraform Cloud watches Git repo"
- "Automatic runs on every push"
- "Professional UI for teams"

---

## 🔧 Demo 2: GitHub Actions (10 minutes)

**Show: "Traditional CI/CD Approach"**

### Setup (Before Demo)
```bash
# Activate Azure backend
mv terraform/backend-azure.tf.example terraform/backend.tf

# GitHub secrets already configured
```

### Demo Flow

1. **Show DEPLOYMENT_MODE.md**
   - Explain pipeline approach
   - When to use this vs Terraform Cloud

2. **Show GitHub Actions Workflow**
   - Open `.github/workflows/terraform.yml`
   - Explain stages: Setup, Validate, Plan, Apply

3. **Create a PR**
   ```bash
   git checkout -b add-tags
   # Make a change
   git add . && git commit -m "Add environment tags"
   git push origin add-tags
   ```

4. **Show PR in GitHub**
   - Actions tab shows workflow running
   - Plan appears as PR comment
   - Review Terraform plan

5. **Merge PR**
   - Merge to main
   - Watch Actions tab
   - Show apply stage running

6. **Show Azure Portal**
   - Resources created
   - Compare with Terraform outputs

**Key Points:**
- "Backend storage auto-created"
- "Plan shown in PR comments"
- "Only applies on merge to main"
- "Good for Azure-centric orgs"

---

## 📊 Comparison Demo

**Show side-by-side:**

| Aspect | Terraform Cloud | GitHub Actions |
|--------|----------------|----------------|
| Setup time | 5 min | 10 min |
| Push to Git | Auto-run | Auto-run |
| UI | TF Cloud | GitHub |
| State | TF Cloud | Azure Storage |
| Best for | Demos, teams | GitHub users |

---

## Common Demo Questions

**Q: Why two options?**
A: Different orgs have different needs. Terraform Cloud is faster for demos, pipelines give more control.

**Q: Can I switch between them?**
A: Yes! Use `terraform init -migrate-state` to move state.

**Q: Which is more secure?**
A: Both are secure. Pipelines keep state in your Azure, TF Cloud uses HashiCorp's infrastructure.

**Q: What about cost?**
A: Both have free tiers. TF Cloud free up to 500 resources. GitHub Actions free for public repos.

**Q: Can I use Azure DevOps instead?**
A: Yes! `azure-pipelines.yml` is included. See docs/azure-devops-setup.md

---

## Demo Tips

1. ✅ Have both modes pre-configured
2. ✅ Keep changes small for faster demos
3. ✅ Use dev/small resources to save money
4. ✅ Prepare Azure Portal view beforehand
5. ✅ Have destroy workflows ready
6. ✅ Test both flows before presenting

---

## Cleanup After Demo

**Terraform Cloud:**
```bash
# In TF Cloud UI: Queue destroy plan
# Or locally:
terraform destroy
```

**GitHub Actions:**
```bash
# Trigger destroy workflow
# Actions → Terraform Destroy → Run workflow
```

**Or manually:**
```bash
cd terraform
terraform destroy -auto-approve
```
