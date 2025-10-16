# GCS Bucket Module

This module creates a Google Cloud Storage bucket with best-practice configurations including lifecycle management, versioning, access controls, and logging.

## Features

- **Security**: Uniform bucket-level access and enforced public access prevention
- **Versioning**: Optional object versioning for data protection
- **Lifecycle Management**: Automated object deletion, archival, and cleanup
- **Access Logging**: Optional access log storage to another bucket
- **Labels**: Customizable resource labels for organization and billing

## Usage

### Basic Example

```hcl
module "simple_bucket" {
  source = "./modules/gcs-bucket"

  project_id  = "my-project-id"
  bucket_name = "my-unique-bucket-name"
  location    = "US"
}
```

### Advanced Example

```hcl
module "production_bucket" {
  source = "./modules/gcs-bucket"

  project_id         = "my-project-id"
  bucket_name        = "prod-data-bucket-${random_id.suffix.hex}"
  location           = "US"
  storage_class      = "STANDARD"
  versioning_enabled = true
  lifecycle_age_days = 90
  log_bucket         = "logs-bucket"

  labels = {
    environment = "production"
    team        = "data-engineering"
    cost_center = "engineering"
    compliance  = "required"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
```

## Lifecycle Rules

This module implements three lifecycle rules:

### 1. Delete Old Objects
Automatically deletes objects after a specified number of days.

```hcl
lifecycle_rule {
  condition {
    age = var.lifecycle_age_days  # Default: 30 days
  }
  action {
    type = "Delete"
  }
}
```

### 2. Archive Old Versions
Moves archived versions from STANDARD to ARCHIVE storage class after 90 days.

```hcl
lifecycle_rule {
  action {
    type          = "SetStorageClass"
    storage_class = "ARCHIVE"
  }
  condition {
    age                   = 90
    with_state            = "ARCHIVED"
    matches_storage_class = ["STANDARD"]
  }
}
```

### 3. Abort Incomplete Multipart Uploads
Cleans up incomplete uploads after 7 days to prevent storage waste.

```hcl
lifecycle_rule {
  action {
    type = "AbortIncompleteMultipartUpload"
  }
  condition {
    age = 7
  }
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | GCP Project ID | `string` | - | yes |
| `bucket_name` | Unique name for the GCS bucket | `string` | - | yes |
| `location` | Bucket location (region or multi-region) | `string` | `"US"` | no |
| `storage_class` | Storage class for objects | `string` | `"STANDARD"` | no |
| `versioning_enabled` | Enable object versioning | `bool` | `true` | no |
| `lifecycle_age_days` | Days before objects are deleted | `number` | `30` | no |
| `labels` | Resource labels for organization | `map(string)` | `{}` | no |
| `log_bucket` | Bucket for access logs (optional) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| `name` | The name of the created bucket |
| `url` | The base URL of the bucket (gs://...) |
| `self_link` | The URI of the created resource |

## Storage Classes

Choose the appropriate storage class based on access patterns:

- **STANDARD**: Frequently accessed data (default)
- **NEARLINE**: Accessed less than once per month
- **COLDLINE**: Accessed less than once per quarter
- **ARCHIVE**: Long-term archival, accessed less than once per year

## Location Types

### Multi-Region
- `US`: United States multi-region
- `EU`: European Union multi-region
- `ASIA`: Asia multi-region

### Region (examples)
- `us-central1`: Iowa
- `us-east1`: South Carolina
- `europe-west1`: Belgium
- `asia-northeast1`: Tokyo

See the [GCP locations documentation](https://cloud.google.com/storage/docs/locations) for all options.

## Security Considerations

### Uniform Bucket-Level Access
This module enforces **uniform bucket-level access**, which:
- Disables legacy ACLs
- Uses only IAM for access control
- Simplifies permission management
- Recommended for all new buckets

### Public Access Prevention
**Enforced** by default, preventing:
- Public bucket access
- Public object access
- Accidental data exposure

To grant access, use the `gcs-bucket-iam` module with appropriate IAM roles.

## Best Practices

1. **Unique Naming**: Use random suffixes for globally unique bucket names
   ```hcl
   bucket_name = "my-bucket-${random_id.suffix.hex}"
   ```

2. **Labels**: Always include organizational labels
   ```hcl
   labels = {
     environment = "production"
     managed_by  = "terraform"
     team        = "platform"
   }
   ```

3. **Lifecycle Rules**: Adjust `lifecycle_age_days` based on data retention requirements

4. **Versioning**: Enable for critical data to prevent accidental deletion

5. **Logging**: Configure `log_bucket` for audit and compliance requirements

## Examples

### Development Bucket
```hcl
module "dev_bucket" {
  source = "./modules/gcs-bucket"

  project_id         = "dev-project"
  bucket_name        = "dev-temp-data"
  location           = "us-central1"
  versioning_enabled = false
  lifecycle_age_days = 7  # Clean up after 1 week

  labels = {
    environment = "development"
    temporary   = "true"
  }
}
```

### Compliance Bucket
```hcl
module "compliance_bucket" {
  source = "./modules/gcs-bucket"

  project_id         = "prod-project"
  bucket_name        = "compliance-records"
  location           = "US"
  storage_class      = "COLDLINE"
  versioning_enabled = true
  lifecycle_age_days = 2555  # 7 years
  log_bucket         = "audit-logs-bucket"

  labels = {
    environment = "production"
    compliance  = "sox"
    retention   = "7years"
  }
}
```

## Troubleshooting

### Bucket Already Exists
**Error**: `googleapi: Error 409: You already own this bucket`

**Solution**: Bucket names are globally unique. Add a random suffix:
```hcl
bucket_name = "my-bucket-${random_id.suffix.hex}"
```

### Permission Denied
**Error**: `Error creating bucket: googleapi: Error 403: ... does not have storage.buckets.create access`

**Solution**: Ensure your service account has the `roles/storage.admin` role:
```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:SA_EMAIL" \
  --role="roles/storage.admin"
```

### Lifecycle Rule Not Working
**Issue**: Objects not being deleted as expected

**Check**:
1. Verify `lifecycle_age_days` is set correctly
2. Wait 24-48 hours (lifecycle rules run daily)
3. Check object timestamps in the GCP Console

## Related Modules

- **[gcs-bucket-iam](../gcs-bucket-iam/)**: Manage bucket IAM permissions
- **[gcs-bucket-notification](../gcs-bucket-notification/)**: Configure Pub/Sub notifications

## References

- [GCS Bucket Documentation](https://cloud.google.com/storage/docs/creating-buckets)
- [Lifecycle Management](https://cloud.google.com/storage/docs/lifecycle)
- [Storage Classes](https://cloud.google.com/storage/docs/storage-classes)
- [Terraform GCS Resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)

## Support

For issues or questions:
- Open an issue in the [repository](https://github.com/intuitivetp/terraform-gcs-poc/issues)
- Contact the Platform Engineering team on Slack: #platform-engineering

