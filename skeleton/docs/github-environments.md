# GitHub Environments Setup (Optional)

GitHub Environments add approval gates and deployment protection to your workflows.

## What Are GitHub Environments?

Environments allow you to configure:
- ✅ **Required reviewers** - Who must approve before deployment
- ✅ **Wait timer** - Delay before deployment (e.g., 5 minutes)
- ✅ **Deployment branches** - Which branches can deploy to this environment
- ✅ **Environment secrets** - Separate secrets per environment

## Do You Need This?

| If you want... | Need Environment? |
|---------------|-------------------|
| Auto-deploy on push to main | ❌ No |
| Manual approval before deploy | ✅ Yes |
| Different secrets per environment | ✅ Yes |
| Quick demos/testing | ❌ No |
| Production safety | ✅ Yes |

## Manual Setup (If Not Using Backstage Action)

If the `github:environment:create` Backstage action isn't available, create manually:

### 1. Go to GitHub Repository

1. Navigate to your repository
2. Go to **Settings** → **Environments**
3. Click **New environment**

### 2. Create Environment

1. Name: `${{ values.environment }}` (e.g., "dev", "staging", "prod")
2. Click **Configure environment**

### 3. Configure Protection Rules

#### Option A: No Protection (Auto-Deploy)
- Leave all options unchecked
- Click **Save protection rules**

#### Option B: Require Approval (Recommended for Production)
- ✅ Check **Required reviewers**
- Add team members who can approve
- Optionally: Set **Wait timer** (e.g., 5 minutes)
- Click **Save protection rules**

#### Option C: Branch Protection
- Under **Deployment branches**
- Select **Protected branches only** or **Selected branches**
- Choose which branches can deploy
- Click **Save**

### 4. Add Environment Secrets (Optional)

If you want different Azure credentials per environment:

1. In the environment settings
2. Click **Add secret**
3. Add:
   - `AZURE_SUBSCRIPTION_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_CLIENT_ID`
   - `AZURE_CLIENT_SECRET`
   - `AZURE_CREDENTIALS`

These override repository-level secrets for this environment.

## How It Works in Workflows

When a workflow references an environment:

```yaml
jobs:
  deploy:
    environment: production  # References the environment
    steps:
      - name: Deploy
        run: terraform apply
```

The workflow will:
1. Pause before the job runs
2. Wait for required reviewers to approve (if configured)
3. Use environment-specific secrets (if configured)
4. Track deployment in the environment dashboard

## Workflow Changes for Environments

To use environments in your GitHub Actions workflow:

### Current Workflow (No Environment)

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Terraform Apply
        run: terraform apply -auto-approve
```

### With Environment Protection

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    environment: ${{ values.environment }}  # Add this line
    steps:
      - name: Terraform Apply
        run: terraform apply -auto-approve
```

The workflow already includes this for the apply job:

```yaml
environment: ${{ values.environment }}
```

## View Deployment History

After setting up environments:

1. Go to repository → **Code** tab
2. Right sidebar → **Deployments**
3. See history of all deployments
4. Click on a deployment to see details

## Example: Production Environment Setup

For a production environment with strong protection:

```yaml
Environment name: prod

Protection rules:
✅ Required reviewers: @team-leads
✅ Wait timer: 10 minutes
✅ Deployment branches: Protected branches only

Secrets:
- AZURE_SUBSCRIPTION_ID: <prod-subscription>
- AZURE_TENANT_ID: <prod-tenant>
- AZURE_CLIENT_ID: <prod-sp>
- AZURE_CLIENT_SECRET: <prod-secret>
```

## Disable Environment Protection

To remove approval gates:

1. Go to **Settings** → **Environments**
2. Click on the environment
3. Uncheck **Required reviewers**
4. Click **Save protection rules**

Or delete the environment entirely:
1. Click **Delete environment**
2. Confirm deletion

Workflows will still work, just without the approval step.

## Troubleshooting

### Workflow hangs waiting for approval

**Problem:** Job stuck on "Waiting for approval"

**Solution:** 
- Approve the deployment in the Environments view
- Or remove required reviewers from environment settings

### Can't find Environments settings

**Problem:** No "Environments" in Settings menu

**Solution:** 
- Ensure repository is not a fork
- Check you have admin access to the repository
- Public repos: Available on free tier
- Private repos: Requires GitHub Pro/Team/Enterprise

### Environment secrets not working

**Problem:** Workflow uses repository secrets instead of environment secrets

**Solution:**
- Verify `environment:` is specified in the job
- Environment secrets override repository secrets only when environment is referenced

## Best Practices

1. ✅ **Dev/Staging**: Use auto-deploy (no approvals)
2. ✅ **Production**: Require approvals from 2+ people
3. ✅ **Secrets**: Use environment secrets for prod, repository secrets for dev
4. ✅ **Branches**: Restrict prod deployments to `main` branch only
5. ✅ **Notifications**: Enable email/Slack notifications for deployments

## Alternative: Manual Approvals in Workflow

If you don't want to use GitHub Environments, add manual approval in the workflow:

```yaml
- name: Wait for approval
  uses: trstringer/manual-approval@v1
  with:
    approvers: user1,user2
    minimum-approvals: 1
```

But GitHub Environments provide a better integrated experience.

## Summary

- **Optional feature** - Template works without it
- **Use for production** - Adds approval gates
- **Skip for demos** - Auto-deploy is faster
- **Manual setup** - If Backstage action unavailable
- **Configure in GitHub** - Settings → Environments

For quick testing, you don't need this. For production, highly recommended!
