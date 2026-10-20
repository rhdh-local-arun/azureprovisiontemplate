# Terraform Cloud Setup Guide

This guide shows how to use Terraform Cloud for automatic infrastructure deployment without pipelines.

## What is Terraform Cloud?

Terraform Cloud is HashiCorp's SaaS platform that:
- ✅ Watches your Git repository
- ✅ Automatically runs Terraform on every push
- ✅ Manages state remotely
- ✅ Provides collaboration features
- ✅ Shows plan/apply history in a nice UI

**Think of it as "Terraform as a Service"** - you push to Git, it handles the rest.

## Setup Steps

### 1. Create Terraform Cloud Account

1. Go to https://app.terraform.io/signup
2. Sign up (free tier is fine)
3. Create or join an organization
4. Note your organization name (e.g., `mycompany`)

### 2. Activate Terraform Cloud Backend

In your repository:

```bash
# Activate the Terraform Cloud backend
cd terraform
mv backend-cloud.tf.example backend.tf

# Update organization name in backend.tf
# Edit the file and change "YOUR_ORG_NAME" to your org name
```

### 3. Login from CLI

```bash
terraform login
```

This will:
- Open a browser
- Ask you to create an API token
- Save the token locally

### 4. Initialize Terraform

```bash
terraform init
```

This creates the workspace in Terraform Cloud.

### 5. Configure Azure Credentials

In Terraform Cloud UI:

1. Go to your workspace: `${{ values.name }}-${{ values.environment }}`
2. Click **Variables**
3. Add **Environment Variables** (mark as sensitive):

| Variable | Value | Sensitive |
|----------|-------|-----------|
| `ARM_CLIENT_ID` | Your Azure service principal client ID | ✅ |
| `ARM_CLIENT_SECRET` | Your service principal secret | ✅ |
| `ARM_SUBSCRIPTION_ID` | Your Azure subscription ID | ✅ |
| `ARM_TENANT_ID` | Your Azure tenant ID | ✅ |

**How to get these values:**

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "${{ values.name }}-terraform" \
  --role Contributor \
  --scopes /subscriptions/<subscription-id>

# Output shows:
# {
#   "appId": "<client_id>",
#   "password": "<client_secret>",
#   "tenant": "<tenant_id>"
# }
```

### 6. Connect to Git Repository

In Terraform Cloud workspace:

1. Go to **Settings** → **Version Control**
2. Click **Connect to VCS**
3. Choose your Git provider (GitHub, GitLab, etc.)
4. Authorize Terraform Cloud
5. Select this repository
6. Set **Terraform Working Directory** to: `terraform`
7. Save settings

### 7. Configure Auto-Apply (Optional)

For automatic deployments:

1. Go to **Settings** → **General**
2. Under **Apply Method**, select **Auto apply**
3. Save

**Warning:** Auto-apply runs `terraform apply` without manual approval. 
For production, keep manual apply and require plan review.

### 8. Test It!

```bash
# Make a small change
echo "# Test change" >> terraform/main.tf

# Commit and push
git add .
git commit -m "Test Terraform Cloud integration"
git push origin main
```

**Watch in Terraform Cloud UI:**
1. Go to your workspace
2. See the run automatically start
3. Review the plan
4. Click **Confirm & Apply** (if auto-apply is off)
5. Watch resources get created!

## Understanding Runs

### What Triggers a Run?

- ✅ Push to `main` branch (or configured branch)
- ✅ Pull request (plan only)
- ✅ Manual trigger via UI
- ✅ API call

### Run Phases

```
1. Plan Started → Terraform plans changes
2. Cost Estimation → Shows estimated cost (if enabled)
3. Policy Check → Checks Sentinel policies (if configured)
4. Apply (Waiting) → Needs approval (unless auto-apply)
5. Apply Started → Terraform applies changes
6. Completed → Done!
```

## Features to Demo

### 1. Plan on Pull Requests

When you create a PR:
- Terraform Cloud automatically runs a plan
- Posts the plan as a PR comment (if VCS integration configured)
- No apply, just preview

### 2. State Versioning

- Every run creates a new state version
- View history: **States** tab
- Rollback if needed

### 3. Cost Estimation

Enable in workspace settings:
- See estimated monthly cost before applying
- Great for budget awareness

### 4. Collaboration

Invite team members:
- **Settings** → **Team Access**
- Assign roles: Read, Plan, Write, Admin
- Track who applied what

### 5. Notifications

Get Slack/email alerts:
- **Settings** → **Notifications**
- Configure for run status changes

## Workspace Settings

### General Settings

| Setting | Recommendation | Why |
|---------|---------------|-----|
| **Execution Mode** | Remote | Terraform runs in TF Cloud |
| **Apply Method** | Manual (demo: Auto) | Manual is safer for prod |
| **Terraform Version** | Latest 1.5.x | Matches our code |

### Variables

Two types:

**Terraform Variables** - For `variables.tf`:
```
project_name = "${{ values.name }}"
environment = "${{ values.environment }}"
```

**Environment Variables** - For providers:
```
ARM_CLIENT_ID = "..."
ARM_CLIENT_SECRET = "..."
```

## Troubleshooting

### "No valid credential sources found"

**Problem:** Azure credentials not set.

**Solution:** Add all 4 ARM_* environment variables as shown above.

### "Backend initialization required"

**Problem:** Local state exists.

**Solution:**
```bash
rm -rf .terraform/
terraform init
```

### Runs not triggering on push

**Problem:** VCS not connected or wrong branch.

**Solution:**
1. Check **Settings** → **Version Control**
2. Verify branch name matches
3. Check webhook in Git provider settings

### Plan shows no changes but resources don't exist

**Problem:** State is out of sync.

**Solution:**
1. **States** tab → Download current state
2. Review what Terraform thinks exists
3. May need to import or recreate workspace

## Advanced Features

### 1. Run Triggers

Trigger runs across workspaces:
- Create dependencies between workspaces
- Example: Networking workspace → AKS workspace

### 2. Sentinel Policies

Enforce rules before apply:
```hcl
# Example: Require tags
import "tfplan/v2" as tfplan

main = rule {
  all tfplan.resource_changes as _, rc {
    rc.change.after.tags contains "Environment"
  }
}
```

### 3. Private Registry

Share Terraform modules:
- Publish modules to your org's registry
- Version control
- Reuse across teams

## Best Practices

1. ✅ **Use manual apply for prod** - Review plans before applying
2. ✅ **Enable Sentinel policies** - Enforce standards
3. ✅ **Separate workspaces per environment** - dev, staging, prod
4. ✅ **Use workspace variables** - Don't hardcode credentials
5. ✅ **Enable notifications** - Stay informed
6. ✅ **Review state versions** - Understand changes over time
7. ✅ **Use VCS-driven workflow** - Let Git trigger runs

## Cost

**Free tier includes:**
- Up to 500 resources managed
- 5 users
- All core features
- Community support

**Paid tiers add:**
- More resources
- SSO
- Private registry
- Advanced policies
- Premium support

For this demo, free tier is perfect!

## Comparison with Pipelines

| Feature | Terraform Cloud | GitHub Actions | Azure DevOps |
|---------|-----------------|----------------|--------------|
| Setup complexity | Low | Medium | Medium-High |
| Terraform-specific UI | ✅ Yes | ❌ No | ❌ No |
| State locking | ✅ Built-in | ⚠️ Need Azure Storage | ⚠️ Need Azure Storage |
| Plan on PR | ✅ Native | ✅ Via workflow | ⚠️ Needs extension |
| Cost estimation | ✅ Built-in | ❌ No | ❌ No |
| Policy as code | ✅ Sentinel | ⚠️ Custom | ⚠️ Custom |
| Best for demo | ✅ Yes | ⚠️ Good | ⚠️ Good |

## Next Steps

After setup:
1. Push changes to Git
2. Watch runs in Terraform Cloud UI
3. Review plan before applying
4. Check Azure Portal for created resources
5. Explore Terraform Cloud features

## Resources

- Terraform Cloud Docs: https://developer.hashicorp.com/terraform/cloud-docs
- VCS Integration: https://developer.hashicorp.com/terraform/cloud-docs/vcs
- Sentinel Policies: https://developer.hashicorp.com/sentinel
