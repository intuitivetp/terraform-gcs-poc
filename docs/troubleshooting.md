# Troubleshooting Guide

This guide provides solutions to common issues you may encounter when working with the terraform-gcs-poc project.

## Table of Contents

- [Terraform Issues](#terraform-issues)
- [GCP Authentication](#gcp-authentication)
- [Bucket Issues](#bucket-issues)
- [IAM and Permissions](#iam-and-permissions)
- [Testing Issues](#testing-issues)
- [CI/CD Issues](#cicd-issues)

## Terraform Issues

### Terraform Init Fails

**Error:**
```
Error: Failed to query available provider packages
```

**Solutions:**
1. Check internet connectivity
2. Verify Terraform version compatibility:
   ```bash
   terraform version  # Should be >= 1.0
   ```
3. Clear Terraform cache and reinitialize:
   ```bash
   rm -rf .terraform .terraform.lock.hcl
   terraform init
   ```

### Terraform Plan Shows Unexpected Changes

**Issue:** Resources show changes when you haven't modified anything

**Possible Causes:**
1. **State drift**: Someone manually changed resources in GCP Console
2. **Provider version change**: Different provider version interprets configuration differently

**Solutions:**
1. Refresh state:
   ```bash
   terraform refresh
   terraform plan
   ```
2. Import manually changed resources:
   ```bash
   terraform import google_storage_bucket.example bucket-name
   ```
3. Lock provider version in `terraform.tf`:
   ```hcl
   required_providers {
     google = {
       source  = "hashicorp/google"
       version = "5.10.0"  # Specific version
     }
   }
   ```

### State Lock Errors

**Error:**
```
Error: Error locking state: Error acquiring the state lock
```

**Solutions:**
1. Wait for other Terraform operations to complete
2. Force unlock if operation is stuck:
   ```bash
   terraform force-unlock LOCK_ID
   ```
   ⚠️ Only use if you're certain no other process is running

## GCP Authentication

### Application Default Credentials Not Found

**Error:**
```
Error: google: could not find default credentials
```

**Solutions:**
1. Authenticate with gcloud:
   ```bash
   gcloud auth application-default login
   ```
2. Or set service account key:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"
   ```

### Wrong Project Selected

**Error:**
```
Error: Error creating bucket: googleapi: Error 403: The project to be billed is associated with an absent billing account
```

**Solutions:**
1. Verify current project:
   ```bash
   gcloud config get-value project
   ```
2. Set correct project:
   ```bash
   gcloud config set project PROJECT_ID
   ```
3. Or specify in Terraform variables:
   ```bash
   terraform apply -var="project_id=YOUR_PROJECT_ID"
   ```

### Service Account Key Issues

**Error:**
```
Error: Error parsing service account key: invalid character 'C' looking for beginning of value
```

**Solutions:**
1. Verify JSON key file is valid:
   ```bash
   cat key.json | jq .
   ```
2. Download new key from GCP Console
3. Ensure no extra characters or newlines in key file

## Bucket Issues

### Bucket Already Exists

**Error:**
```
Error: Error creating bucket: googleapi: Error 409: You already own this bucket. Please select another name.
```

**Solutions:**
1. Use a different bucket name (must be globally unique)
2. Add random suffix to bucket name:
   ```hcl
   resource "random_id" "suffix" {
     byte_length = 4
   }
   
   module "bucket" {
     source      = "./modules/gcs-bucket"
     bucket_name = "my-bucket-${random_id.suffix.hex}"
   }
   ```
3. If you own the bucket but it's not in state:
   ```bash
   terraform import module.bucket.google_storage_bucket.bucket bucket-name
   ```

### Bucket Deletion Fails

**Error:**
```
Error: Error deleting bucket: googleapi: Error 409: The bucket you tried to delete was not empty
```

**Solutions:**
1. Delete all objects first:
   ```bash
   gsutil -m rm -r gs://bucket-name/**
   ```
2. Or use `force_destroy` in module:
   ```hcl
   resource "google_storage_bucket" "bucket" {
     # ... other config ...
     force_destroy = true  # Allows deletion of non-empty bucket
   }
   ```
   ⚠️ Use with caution in production

### Cannot Access Bucket

**Error:**
```
AccessDeniedException: 403 Caller does not have storage.objects.list access
```

**Solutions:**
1. Check IAM permissions:
   ```bash
   gcloud storage buckets describe gs://bucket-name
   ```
2. Grant yourself access:
   ```bash
   gsutil iam ch user:your-email@example.com:objectViewer gs://bucket-name
   ```
3. Or use Terraform IAM module:
   ```hcl
   module "bucket_iam" {
     source  = "./modules/gcs-bucket-iam"
     bucket  = "bucket-name"
     role    = "roles/storage.objectViewer"
     members = ["user:your-email@example.com"]
   }
   ```

### Public Access Blocked

**Error:**
```
Error: Error applying IAM policy for bucket: googleapi: Error 412: Public access prevention is 'enforced'
```

**Explanation:** The bucket has public access prevention enforced (by design)

**Solutions:**
1. For internal access, use IAM roles instead of making public
2. If you truly need public access (rare), you would need to modify the module to set:
   ```hcl
   public_access_prevention = "inherited"
   ```
   ⚠️ Not recommended for production

## IAM and Permissions

### Permission Denied Creating Resources

**Error:**
```
Error: Error creating bucket: googleapi: Error 403: [EMAIL] does not have storage.buckets.create access to the Google Cloud project
```

**Solutions:**
1. Grant required role:
   ```bash
   gcloud projects add-iam-policy-binding PROJECT_ID \
     --member="user:YOUR_EMAIL" \
     --role="roles/storage.admin"
   ```
2. Common required roles:
   - `roles/storage.admin` - Full storage management
   - `roles/iam.serviceAccountUser` - Use service accounts
   - `roles/pubsub.admin` - Manage Pub/Sub (for notifications)

### Invalid Member Format in IAM Binding

**Error:**
```
Error: Error applying IAM policy: Invalid member format
```

**Solutions:**
1. Ensure correct member prefix:
   ```hcl
   # ✅ Correct formats
   members = [
     "user:alice@example.com",
     "serviceAccount:my-sa@project.iam.gserviceaccount.com",
     "group:team@example.com",
     "domain:example.com"
   ]
   
   # ❌ Incorrect (missing prefix)
   members = [
     "alice@example.com"  # Missing "user:" prefix
   ]
   ```

### Cannot Grant Pub/Sub Publisher Permission

**Error:**
```
Error: Error setting IAM policy for topic: The caller does not have permission
```

**Solution:** Grant GCS service account permission to publish:
```bash
PROJECT_NUMBER=$(gcloud projects describe PROJECT_ID --format="value(projectNumber)")

gcloud pubsub topics add-iam-policy-binding TOPIC_NAME \
  --member="serviceAccount:service-${PROJECT_NUMBER}@gs-project-accounts.iam.gserviceaccount.com" \
  --role="roles/pubsub.publisher"
```

## Testing Issues

### Test Timeout

**Error:**
```
panic: test timed out after 10m0s
```

**Solutions:**
1. Increase timeout:
   ```bash
   go test -v -timeout 30m
   ```
2. Check if GCP operations are actually failing (not just slow)
3. Run with more verbosity to see where it hangs:
   ```bash
   go test -v -timeout 30m 2>&1 | tee test.log
   ```

### Tests Failing with "Already Exists"

**Error:**
```
Error: Error creating bucket: googleapi: Error 409: You already own this bucket
```

**Solutions:**
1. Ensure tests use unique names:
   ```go
   uniqueID := random.UniqueId()
   bucketName := fmt.Sprintf("test-%s", strings.ToLower(uniqueID))
   ```
2. Clean up leftover resources from failed tests:
   ```bash
   gsutil ls | grep test-
   gsutil -m rm -r gs://test-bucket-name
   ```

### Go Module Download Issues

**Error:**
```
go: github.com/gruntwork-io/terratest@latest: Get "https://proxy.golang.org/...": dial tcp: lookup proxy.golang.org: no such host
```

**Solutions:**
1. Check internet connectivity
2. Configure Go proxy:
   ```bash
   export GOPROXY=https://proxy.golang.org,direct
   ```
3. Or download dependencies manually:
   ```bash
   cd tests
   go mod download
   ```

### Terratest Not Finding Terraform

**Error:**
```
Error: Terraform executable not found
```

**Solutions:**
1. Verify Terraform is installed and in PATH:
   ```bash
   which terraform
   terraform version
   ```
2. Add Terraform to PATH:
   ```bash
   export PATH=$PATH:/path/to/terraform
   ```

## CI/CD Issues

### GitHub Actions: Authentication Failed

**Error:**
```
Error: google: could not find default credentials
```

**Solutions:**
1. Ensure service account key is configured as secret
2. Add authentication step to workflow:
   ```yaml
   - name: Authenticate to GCP
     uses: google-github-actions/auth@v2
     with:
       credentials_json: ${{ secrets.GCP_SA_KEY }}
   ```

### GitHub Actions: Tests Fail but Pass Locally

**Possible Causes:**
1. Different GCP project
2. Missing environment variables
3. Insufficient permissions for service account
4. Resource quota limits

**Solutions:**
1. Verify environment variables in workflow:
   ```yaml
   env:
     GOOGLE_PROJECT: ${{ secrets.GCP_PROJECT_ID }}
   ```
2. Check service account has all required roles
3. Review Cloud Build logs for detailed errors

### Terraform Format Check Fails

**Error:**
```
Error: Terraform files are not formatted correctly
```

**Solutions:**
1. Format files locally:
   ```bash
   terraform fmt -recursive
   ```
2. Configure pre-commit hook:
   ```bash
   cat > .git/hooks/pre-commit << 'EOF'
   #!/bin/bash
   terraform fmt -check -recursive
   EOF
  chmod +x .git/hooks/pre-commit
  ```

### Real Apply Mode Fails Immediately

**Symptoms:**
- Workflow stops in the “Prepare Terraform State” job with errors about missing credentials, project IDs, or state buckets.

**Solutions:**
1. Verify workflow inputs: only set `run_real_apply=true` when you intend to deploy to GCP.
2. Provide required secrets:
   - `GCP_CREDENTIALS` (service account JSON with appropriate roles)
   - `GCP_PROJECT_ID` (target project for the apply)
   - `TF_STATE_BUCKET` (existing GCS bucket for Terraform state)
3. Confirm the Terraform backend bucket exists and is accessible by the service account.
4. Trigger the workflow via **Actions → Run workflow** so you can toggle `run_real_apply` explicitly; standard push/PR runs default to mock mode.

## Getting Help

If you can't resolve your issue:

### 1. Check Logs
```bash
# Terraform debug logs
export TF_LOG=DEBUG
terraform apply

# GCP logs
gcloud logging read "resource.type=gcs_bucket" --limit 50 --format json
```

### 2. Verify Configuration
```bash
# Check current GCP project
gcloud config list

# Verify Terraform configuration
terraform validate

# Check Terraform state
terraform show
```

### 3. Review Documentation
- [Terraform GCP Provider Docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCS Documentation](https://cloud.google.com/storage/docs)
- [Terratest Documentation](https://terratest.gruntwork.io/docs/)

### 4. Ask for Help
- **GitHub Issues**: [Create an issue](https://github.com/intuitivetp/terraform-gcs-poc/issues/new)
- **Slack**: #platform-engineering channel
- **Confluence**: [Project page](https://intuitive-cloud.atlassian.net/wiki/spaces/ape/pages/35454977/)

### 5. Include Debug Information
When reporting issues, include:
- Terraform version: `terraform version`
- Provider version: Check `terraform.lock.hcl`
- Error message (full output)
- Steps to reproduce
- GCP project ID (if not sensitive)
- Relevant code snippets

## Common Debugging Commands

```bash
# Terraform debugging
terraform validate              # Validate configuration syntax
terraform plan                  # Preview changes
terraform show                  # Show current state
terraform state list            # List all resources in state
terraform console               # Interactive console for testing expressions

# GCP debugging
gcloud projects describe PROJECT_ID                    # Project details
gcloud storage buckets list                            # List all buckets
gcloud storage buckets describe gs://BUCKET            # Bucket details
gcloud iam service-accounts list                       # List service accounts
gcloud projects get-iam-policy PROJECT_ID              # Project IAM policy

# Test debugging
go test -v                      # Verbose test output
go test -v -run TestName        # Run specific test
go test -v -timeout 30m         # Increase timeout
TF_LOG=DEBUG go test -v         # Terraform debug logs during tests
```

## Preventive Measures

### 1. Use Version Constraints
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"  # Pin to major version
    }
  }
}
```

### 2. Validate Before Apply
```bash
terraform fmt -check
terraform validate
terraform plan
```

### 3. Enable Debug Logging
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform-debug.log
```

### 4. Regular State Backups
```bash
terraform state pull > backup-$(date +%Y%m%d).tfstate
```

### 5. Use Separate Projects for Testing
Don't test in production projects. Use:
- `project-dev` for development
- `project-test` for automated testing
- `project-prod` for production

---

**Still having issues?** Don't hesitate to reach out to the Platform Engineering team on Slack (#platform-engineering) or open a GitHub issue.
