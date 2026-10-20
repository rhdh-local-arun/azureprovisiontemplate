# Azure Secrets Configuration Guide

This document explains where Azure secrets come from and how to configure them.

## 🔐 Where Secrets Are Fetched From

The template references secrets like this:

```yaml
secrets:
  AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
  AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
  AZURE_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
  AZURE_CREDENTIALS: ${{ secrets.AZURE_CREDENTIALS }}
```

These secrets are fetched from **Backstage/RHDH's backend configuration**, NOT from the template itself.

## 📍 Configuration Locations

### Option 1: Backstage Backend Secrets (Recommended)

Configure in your Backstage instance's backend:

**Location:** `app-config.yaml` or `app-config.production.yaml`

```yaml
# In your Backstage app-config
backend:
  # ... other config
  
# Add secrets integration
integrations:
  azure:
    credentials:
      - clientId: ${AZURE_CLIENT_ID}
        clientSecret: ${AZURE_CLIENT_SECRET}
        tenantId: ${AZURE_TENANT_ID}
        subscriptionId: ${AZURE_SUBSCRIPTION_ID}
```

Then set environment variables where Backstage runs:

```bash
export AZURE_CLIENT_ID="your-client-id"
export AZURE_CLIENT_SECRET="your-client-secret"
export AZURE_TENANT_ID="your-tenant-id"
export AZURE_SUBSCRIPTION_ID="your-subscription-id"
```

### Option 2: Kubernetes Secrets (RHDH on OpenShift/K8s)

If running RHDH on Kubernetes/OpenShift:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: azure-credentials
  namespace: backstage
type: Opaque
stringData:
  AZURE_CLIENT_ID: "your-client-id"
  AZURE_CLIENT_SECRET: "your-client-secret"
  AZURE_TENANT_ID: "your-tenant-id"
  AZURE_SUBSCRIPTION_ID: "your-subscription-id"
  AZURE_CREDENTIALS: |
    {
      "clientId": "your-client-id",
      "clientSecret": "your-client-secret",
      "subscriptionId": "your-subscription-id",
      "tenantId": "your-tenant-id"
    }
```

Then mount in your RHDH deployment:

```yaml
envFrom:
  - secretRef:
      name: azure-credentials
```

### Option 3: Vault Integration (Enterprise)

For HashiCorp Vault or similar:

```yaml
# app-config.yaml
backend:
  secrets:
    provider: vault
    vault:
      token: ${VAULT_TOKEN}
      baseUrl: https://vault.example.com
```

## ⚠️ Important Notes

### This Step May Fail!

The `publish:github` step that sets secrets:

```yaml
- id: publish
  name: Publish to Repository
  action: publish:github
  input:
    secrets:
      AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

**Will fail or skip if:**
- ❌ Secrets are not configured in Backstage backend
- ❌ The publish action doesn't support secrets parameter
- ❌ GitHub token lacks permission to set repository secrets

### Alternative: Manual Secret Configuration

If automatic secret injection doesn't work, you have two options:

---

## 🔧 Solution 1: Remove Automatic Secret Injection (Recommended)

Remove the `secrets:` block from template.yaml and have users manually add secrets to their repository.

**Updated template.yaml:**

```yaml
- id: publish
  name: Publish to Repository
  action: publish:github
  input:
    allowedHosts: ['github.com']
    description: ${{ parameters.description }}
    repoUrl: ${{ parameters.repoUrl }}
    defaultBranch: main
    repoVisibility: private
    # REMOVED: secrets block
```

**Then users manually add secrets:**

1. Go to generated GitHub repository
2. Settings → Secrets → Actions
3. Add each secret manually

**Pros:**
- ✅ Always works
- ✅ No Backstage backend configuration needed
- ✅ More secure (secrets stay in GitHub only)

**Cons:**
- ⚠️ Extra manual step for users
- ⚠️ Not fully automated

---

## 🔧 Solution 2: Create Post-Template Instructions

Keep the secrets injection attempt, but add fallback instructions.

Add a `docs/SETUP_SECRETS.md` file to the skeleton that users see after generation:

```markdown
# Setup Azure Secrets

Your repository needs Azure credentials to deploy infrastructure.

## Quick Setup (5 minutes)

1. Create Azure Service Principal:
   
   \`\`\`bash
   az ad sp create-for-rbac \
     --name "myproject-sp" \
     --role Contributor \
     --scopes /subscriptions/<subscription-id> \
     --sdk-auth
   \`\`\`

2. Copy the JSON output

3. In GitHub repository, go to:
   Settings → Secrets and variables → Actions → New repository secret

4. Add these secrets:

   | Secret Name | Value |
   |-------------|-------|
   | AZURE_CREDENTIALS | Entire JSON from step 1 |
   | AZURE_SUBSCRIPTION_ID | From JSON: subscriptionId |
   | AZURE_TENANT_ID | From JSON: tenantId |
   | AZURE_CLIENT_ID | From JSON: clientId |
   | AZURE_CLIENT_SECRET | From JSON: clientSecret |

5. Push to main branch to trigger deployment!
```

---

## 🎯 Recommended Approach

**For Production RHDH:**
1. Configure secrets in Backstage backend (Option 1 or 2 above)
2. Keep automatic secret injection in template
3. Add fallback instructions in README

**For Demo/Testing:**
1. Remove automatic secret injection from template
2. Add clear manual setup instructions
3. Simpler and more reliable

---

## 🔍 How to Check if Secrets Are Configured

### Test in Backstage Backend

Check if secrets are available:

```bash
# SSH into Backstage pod/container
echo $AZURE_CLIENT_ID
echo $AZURE_SUBSCRIPTION_ID
```

If empty, secrets are not configured.

### Test Template Generation

1. Generate a test project from the template
2. Check the created GitHub repository
3. Go to Settings → Secrets → Actions
4. See if secrets were automatically added

If no secrets → automatic injection didn't work → use manual approach

---

## 📚 Additional Resources

- [Backstage Integrations](https://backstage.io/docs/integrations/)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Azure Service Principals](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)
- [RHDH Configuration](https://access.redhat.com/documentation/en-us/red_hat_developer_hub)

---

## Summary

**Secrets Source:** Backstage backend environment variables or secrets manager
**If Not Configured:** Template step may fail or be skipped
**Recommendation:** Use manual secret setup for reliability
**Best Practice:** Store secrets in Kubernetes secrets or Vault, not in config files
