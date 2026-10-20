# Quick Guide: Should I Use GitHub Environments?

## TL;DR

**For Demo/Testing:** ❌ No - Skip it, auto-deploy is fine
**For Production:** ✅ Yes - Add approval gates for safety

## What Happens Without Environments?

```
Push to main → Workflow runs → Terraform applies → Done ✅
```

**Automatic deployment, no manual approval needed.**

## What Happens With Environments?

```
Push to main → Workflow runs → ⏸️ WAITS → You approve → Terraform applies → Done ✅
```

**Manual approval required before applying.**

## How to Enable (2 minutes)

1. **In GitHub:** Settings → Environments → New environment
2. **Name:** `dev` (or `staging`, `prod`)
3. **Add reviewers:** Select who can approve
4. **In workflow:** Uncomment the `environment:` line

Done! Now deployments wait for approval.

## How to Disable

Just leave the `environment:` line commented out in the workflow.

## Full Details

See [github-environments.md](github-environments.md) for complete documentation.
