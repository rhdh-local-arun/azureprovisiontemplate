# Azure DevOps Pipeline Setup

This guide explains how to set up the Azure DevOps pipeline for automatic infrastructure provisioning.

## Prerequisites

1. Azure DevOps organization and project
2. Azure subscription with Contributor access
3. Git repository created by RHDH template

## Setup Steps

### 1. Create Azure Service Connection

In Azure DevOps:

1. Go to **Project Settings** → **Service connections**
2. Click **New service connection**
3. Select **Azure Resource Manager**
4. Choose **Service principal (automatic)** or **Service principal (manual)**

**For Automatic:**
- Select your subscription
- Name it: `Azure-ServiceConnection` (must match pipeline variable)
- Grant access to all pipelines

**For Manual:**
- Use existing service principal credentials
- Name it: `Azure-ServiceConnection`

### 2. Create the Pipeline

1. Go to **Pipelines** → **New pipeline**
2. Select your repository location (GitHub, Azure Repos, etc.)
3. Choose **Existing Azure Pipelines YAML file**
4. Select `/azure-pipelines.yml`
5. Click **Run**

### 3. What Happens on First Run

The pipeline will automatically:

1. ✅ **Create backend storage** (if it doesn't exist)
   - Resource group: `tfstate-rg`
   - Storage account: `tfstate${{ values.name }}`
   - Container: `tfstate`

2. ✅ **Validate Terraform configuration**
   - Format check
   - Validation
   - Init

3. ✅ **Plan infrastructure changes**
   - Shows what will be created

4. ✅ **Apply infrastructure** (only on main branch)
   - Creates all Azure resources

## Pipeline Triggers

The pipeline runs automatically when:

- **Push to `main` branch** → Full validate, plan, and apply
- **Pull request to `main`** → Validate and plan only (no apply)
- **Changes in `terraform/**` directory** → Only when Terraform files change

## Pipeline Stages

```
┌─────────────────┐
│  Setup          │  Create backend storage
│  (Auto)         │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Validate       │  Format, validate, init
│                 │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Plan           │  Preview changes
│                 │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Apply          │  Provision resources
│  (main only)    │  (requires environment approval)
└─────────────────┘
```

## Environment Setup (Optional)

For added safety, create an environment with approvals:

1. Go to **Pipelines** → **Environments**
2. Create environment: `${{ values.environment }}`
3. Add **Approvals and checks**
4. Configure required approvers

The pipeline will pause before `Apply` stage and wait for approval.

## Monitoring Pipeline Runs

1. Go to **Pipelines** → Select your pipeline
2. View run history
3. Click on a run to see:
   - Stage results
   - Terraform plan output
   - Apply results
   - Resource outputs

## Common Issues

### Pipeline Fails: "Service connection not found"

**Solution:** Ensure the service connection is named exactly `Azure-ServiceConnection` or update the variable in `azure-pipelines.yml`:

```yaml
variables:
  azureServiceConnection: 'Your-Connection-Name'
```

### Pipeline Fails: "Insufficient permissions"

**Solution:** Grant the service principal Contributor role:

```bash
az role assignment create \
  --assignee <service-principal-id> \
  --role Contributor \
  --scope /subscriptions/<subscription-id>
```

### Backend Storage Already Exists

**No problem!** The setup stage uses `|| true` to ignore errors if resources already exist.

### Manual Pipeline Trigger

To manually trigger the pipeline:

1. Go to **Pipelines** → Select your pipeline
2. Click **Run pipeline**
3. Select branch (usually `main`)
4. Click **Run**

## Pipeline Variables

You can override these in Azure DevOps:

| Variable | Default | Purpose |
|----------|---------|---------|
| `terraformVersion` | `1.5.7` | Terraform version |
| `azureServiceConnection` | `Azure-ServiceConnection` | Service connection name |
| `backendResourceGroup` | `tfstate-rg` | Backend RG |
| `backendStorageAccount` | `tfstate${{ values.name }}` | Backend storage |

To override:

1. Edit pipeline
2. Click **Variables**
3. Add/modify variables

## Destroying Infrastructure

There is no automated destroy in the pipeline for safety.

To destroy manually:

1. Use the local Terraform CLI (see main README)
2. Or create a separate destroy pipeline with manual approval

## Best Practices

1. ✅ **Use environments with approvals** for production
2. ✅ **Review plan output** before merging to main
3. ✅ **Use branch policies** to require PR reviews
4. ✅ **Enable Azure Policy** for compliance
5. ✅ **Monitor pipeline runs** and set up notifications

## Next Steps

- Configure notifications: **Project Settings** → **Notifications**
- Set up branch policies: **Repos** → **Branches** → **Branch policies**
- Enable continuous monitoring in Azure
- Review Terraform outputs after deployment
