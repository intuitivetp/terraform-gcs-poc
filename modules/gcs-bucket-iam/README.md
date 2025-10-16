# GCS Bucket IAM Module

This module manages IAM (Identity and Access Management) bindings for Google Cloud Storage buckets, allowing you to grant specific roles to users, service accounts, or groups.

## Features

- **IAM Binding Management**: Grant bucket-level permissions to principals
- **Multiple Member Support**: Assign roles to multiple identities at once
- **Best Practices**: Uses IAM bindings for consistent permission management

## Usage

### Basic Example

```hcl
module "bucket_reader" {
  source = "./modules/gcs-bucket-iam"

  bucket = "my-bucket-name"
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:app@my-project.iam.gserviceaccount.com"
  ]
}
```

### Multiple Members

```hcl
module "bucket_writers" {
  source = "./modules/gcs-bucket-iam"

  bucket = module.data_bucket.name
  role   = "roles/storage.objectAdmin"
  members = [
    "serviceAccount:etl-pipeline@my-project.iam.gserviceaccount.com",
    "serviceAccount:data-processor@my-project.iam.gserviceaccount.com",
    "group:data-engineering@mycompany.com"
  ]
}
```

### Complete Example with Bucket

```hcl
module "my_bucket" {
  source = "./modules/gcs-bucket"

  project_id  = "my-project"
  bucket_name = "data-lake-bucket"
  location    = "US"
}

# Allow service account to read objects
module "bucket_read_access" {
  source = "./modules/gcs-bucket-iam"

  bucket = module.my_bucket.name
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:reader@my-project.iam.gserviceaccount.com"
  ]
}

# Allow another service account to write objects
module "bucket_write_access" {
  source = "./modules/gcs-bucket-iam"

  bucket = module.my_bucket.name
  role   = "roles/storage.objectCreator"
  members = [
    "serviceAccount:writer@my-project.iam.gserviceaccount.com"
  ]
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `bucket` | Name of the GCS bucket | `string` | - | yes |
| `role` | IAM role to grant | `string` | - | yes |
| `members` | List of identities to grant the role | `list(string)` | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| `binding` | The IAM binding resource details |

## Common IAM Roles

### Object-Level Roles

| Role | Description | Use Case |
|------|-------------|----------|
| `roles/storage.objectViewer` | Read-only access to objects | Application reading data |
| `roles/storage.objectCreator` | Create objects (no read/delete) | Log collection services |
| `roles/storage.objectUser` | Read and write objects | Data processing pipelines |
| `roles/storage.objectAdmin` | Full control over objects | Application with full data access |

### Bucket-Level Roles

| Role | Description | Use Case |
|------|-------------|----------|
| `roles/storage.legacyBucketReader` | List bucket contents | Monitoring and inventory |
| `roles/storage.legacyBucketWriter` | Create and list objects | Legacy applications |
| `roles/storage.admin` | Full bucket management | Infrastructure automation |

See [GCS IAM roles documentation](https://cloud.google.com/storage/docs/access-control/iam-roles) for all roles.

## Member Types

### Service Account
```hcl
"serviceAccount:SERVICE_ACCOUNT_EMAIL"
```
Example: `serviceAccount:my-app@my-project.iam.gserviceaccount.com`

### User
```hcl
"user:EMAIL_ADDRESS"
```
Example: `user:alice@example.com`

### Group
```hcl
"group:GROUP_EMAIL"
```
Example: `group:data-team@mycompany.com`

### Domain
```hcl
"domain:DOMAIN_NAME"
```
Example: `domain:mycompany.com`

### All Authenticated Users
```hcl
"allAuthenticatedUsers"
```
⚠️ Use with caution - grants access to any authenticated Google account

### All Users (Public)
```hcl
"allUsers"
```
⚠️ **Not recommended** - This module works with buckets that have public access prevention enforced

## Best Practices

### 1. Principle of Least Privilege
Grant the minimum permissions required:
```hcl
# ✅ Good: Grant only read access if that's all that's needed
role = "roles/storage.objectViewer"

# ❌ Bad: Granting admin when only read is needed
role = "roles/storage.admin"
```

### 2. Use Service Accounts
Prefer service accounts over user accounts for applications:
```hcl
members = [
  "serviceAccount:app@project.iam.gserviceaccount.com"  # ✅ Good
  # "user:developer@company.com"  # ❌ Avoid for production
]
```

### 3. Group Management
Use groups for team access:
```hcl
module "team_access" {
  source = "./modules/gcs-bucket-iam"

  bucket = module.shared_bucket.name
  role   = "roles/storage.objectViewer"
  members = [
    "group:data-analysts@mycompany.com"  # Easier to manage
  ]
}
```

### 4. Multiple Role Assignments
Create separate bindings for different roles:
```hcl
# Read access for analysts
module "analyst_access" {
  source  = "./modules/gcs-bucket-iam"
  bucket  = module.bucket.name
  role    = "roles/storage.objectViewer"
  members = ["group:analysts@company.com"]
}

# Write access for pipelines
module "pipeline_access" {
  source  = "./modules/gcs-bucket-iam"
  bucket  = module.bucket.name
  role    = "roles/storage.objectCreator"
  members = ["serviceAccount:etl@project.iam.gserviceaccount.com"]
}
```

## Security Considerations

### Public Access Prevention
The `gcs-bucket` module enforces public access prevention. Attempting to grant public access will fail:
```hcl
# ❌ This will fail if the bucket has public access prevention
members = ["allUsers"]
```

### Uniform Bucket-Level Access
The `gcs-bucket` module uses uniform bucket-level access, which:
- Disables object-level ACLs
- Requires all access control through IAM
- Simplifies permission management

### Audit Logging
Enable Cloud Audit Logs to track IAM changes:
```bash
gcloud logging read "resource.type=gcs_bucket AND protoPayload.methodName:SetIamPolicy"
```

## Examples

### Read-Only Access for Application
```hcl
module "app_read_access" {
  source = "./modules/gcs-bucket-iam"

  bucket = "production-data-bucket"
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:webapp@prod-project.iam.gserviceaccount.com"
  ]
}
```

### ETL Pipeline with Write Access
```hcl
module "etl_access" {
  source = "./modules/gcs-bucket-iam"

  bucket = "data-warehouse-bucket"
  role   = "roles/storage.objectAdmin"
  members = [
    "serviceAccount:etl-pipeline@project.iam.gserviceaccount.com"
  ]
}
```

### Cross-Project Access
```hcl
module "cross_project_access" {
  source = "./modules/gcs-bucket-iam"

  bucket = "shared-analytics-bucket"
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:analytics@other-project.iam.gserviceaccount.com"
  ]
}
```

### Team Access with Groups
```hcl
module "team_bucket_access" {
  source = "./modules/gcs-bucket-iam"

  bucket = "team-collaboration-bucket"
  role   = "roles/storage.objectUser"
  members = [
    "group:engineering@mycompany.com",
    "group:data-science@mycompany.com"
  ]
}
```

## Troubleshooting

### Permission Denied Errors
**Error**: `Error applying IAM policy for storage bucket: googleapi: Error 403`

**Solution**: Ensure you have the `roles/storage.admin` role:
```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:YOUR_EMAIL" \
  --role="roles/storage.admin"
```

### Member Format Issues
**Error**: `Invalid member format`

**Solution**: Ensure correct prefix (`serviceAccount:`, `user:`, `group:`):
```hcl
# ✅ Correct
members = ["serviceAccount:app@project.iam.gserviceaccount.com"]

# ❌ Incorrect
members = ["app@project.iam.gserviceaccount.com"]
```

### Conflicting IAM Bindings
**Issue**: Multiple modules managing the same role

**Solution**: Use `google_storage_bucket_iam_member` instead of `google_storage_bucket_iam_binding` for additive permissions, or consolidate all members for a role into one module.

## Related Modules

- **[gcs-bucket](../gcs-bucket/)**: Create and configure GCS buckets
- **[gcs-bucket-notification](../gcs-bucket-notification/)**: Configure bucket event notifications

## References

- [GCS IAM Overview](https://cloud.google.com/storage/docs/access-control/iam)
- [IAM Roles for Storage](https://cloud.google.com/storage/docs/access-control/iam-roles)
- [Terraform IAM Resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam)

## Support

For issues or questions:
- Open an issue in the [repository](https://github.com/intuitivetp/terraform-gcs-poc/issues)
- Contact the Platform Engineering team on Slack: #platform-engineering

