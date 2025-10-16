# Bucket with IAM Example

This example demonstrates how to create a GCS bucket with comprehensive IAM access control, granting different permission levels to various users, service accounts, and groups.

## What This Creates

- One GCS bucket with versioning enabled
- Three IAM bindings for different access levels:
  - **Readers** (`roles/storage.objectViewer`) - Can list and read objects
  - **Writers** (`roles/storage.objectCreator`) - Can upload objects
  - **Admins** (`roles/storage.objectAdmin`) - Full control over objects

## Use Cases

- Application data storage with role-based access
- Team collaboration with different permission levels
- ETL pipelines with write-only access
- Analytics applications with read-only access
- Separation of duties for security

## Usage

### 1. Configure Variables

Create a `terraform.tfvars` file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your identities:

```hcl
project_id = "my-project"

reader_members = [
  "serviceAccount:analytics@my-project.iam.gserviceaccount.com",
  "group:data-team@company.com"
]

writer_members = [
  "serviceAccount:etl@my-project.iam.gserviceaccount.com"
]

admin_members = [
  "user:admin@company.com"
]
```

### 2. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 3. Verify IAM Bindings

```bash
# View bucket IAM policy
gsutil iam get gs://$(terraform output -raw bucket_name)

# Or use gcloud
gcloud storage buckets get-iam-policy gs://$(terraform output -raw bucket_name)
```

### 4. Test Access

**As a reader:**
```bash
# This should work
gsutil ls gs://BUCKET_NAME/

# This should fail
gsutil cp test.txt gs://BUCKET_NAME/
```

**As a writer:**
```bash
# This should work
gsutil cp test.txt gs://BUCKET_NAME/

# This might fail (no read permission)
gsutil cat gs://BUCKET_NAME/test.txt
```

**As an admin:**
```bash
# Everything should work
gsutil cp test.txt gs://BUCKET_NAME/
gsutil ls gs://BUCKET_NAME/
gsutil rm gs://BUCKET_NAME/test.txt
```

### 5. Clean Up

```bash
terraform destroy
```

## Configuration

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `project_id` | GCP Project ID | - | Yes |
| `reader_members` | List of identities with read access | `[]` | No |
| `writer_members` | List of identities with write access | `[]` | No |
| `admin_members` | List of identities with admin access | `[]` | No |
| `environment` | Environment label | `development` | No |

### Member Format

Use proper IAM member format:

```hcl
reader_members = [
  "user:alice@example.com",                                    # Individual user
  "serviceAccount:app@project.iam.gserviceaccount.com",       # Service account
  "group:team@company.com",                                    # Google Group
  "domain:company.com"                                         # All users in domain
]
```

### Outputs

| Output | Description |
|--------|-------------|
| `bucket_name` | Name of the bucket |
| `bucket_url` | GS URL |
| `reader_binding` | IAM binding for readers (sensitive) |
| `writer_binding` | IAM binding for writers (sensitive) |
| `admin_binding` | IAM binding for admins (sensitive) |

## IAM Roles Explained

### roles/storage.objectViewer (Readers)
**Permissions:**
- ✅ List objects in bucket
- ✅ Read object data
- ✅ Read object metadata
- ❌ Cannot create, modify, or delete objects

**Use for:**
- Analytics applications
- Reporting tools
- Read-only dashboards
- Data scientists needing access to datasets

### roles/storage.objectCreator (Writers)
**Permissions:**
- ✅ Upload new objects
- ❌ Cannot read existing objects
- ❌ Cannot delete objects
- ❌ Cannot list bucket contents

**Use for:**
- ETL pipelines that only write
- Log collection services
- Backup systems
- Applications that shouldn't read existing data

### roles/storage.objectAdmin (Admins)
**Permissions:**
- ✅ Full control over objects
- ✅ Read, write, delete objects
- ✅ Modify object metadata
- ❌ Cannot modify bucket settings (use `roles/storage.admin` for that)

**Use for:**
- Application with full data access
- Data engineering workflows
- Administrative users
- Cleanup and maintenance services

## Architecture Patterns

### Pattern 1: Application with Read/Write Separation

```hcl
# Read-only replica for analytics
reader_members = [
  "serviceAccount:analytics-replica@project.iam.gserviceaccount.com"
]

# Write-only pipeline
writer_members = [
  "serviceAccount:data-ingest@project.iam.gserviceaccount.com"
]

# Admin for main application
admin_members = [
  "serviceAccount:main-app@project.iam.gserviceaccount.com"
]
```

### Pattern 2: Team-Based Access

```hcl
# All team members can read
reader_members = [
  "group:engineering@company.com"
]

# Only data engineers can write
writer_members = [
  "group:data-engineering@company.com"
]

# Only platform team has admin access
admin_members = [
  "group:platform-team@company.com"
]
```

### Pattern 3: Cross-Project Access

```hcl
# Service account from another project
reader_members = [
  "serviceAccount:analytics@other-project.iam.gserviceaccount.com"
]
```

## Security Best Practices

### 1. Principle of Least Privilege
Grant only the minimum permissions needed:
```hcl
# ✅ Good: Grant objectViewer for read-only needs
reader_members = ["serviceAccount:app@project.iam.gserviceaccount.com"]

# ❌ Bad: Granting objectAdmin when only read is needed
admin_members = ["serviceAccount:app@project.iam.gserviceaccount.com"]
```

### 2. Use Service Accounts for Applications
```hcl
# ✅ Good: Service accounts for applications
writer_members = [
  "serviceAccount:etl@project.iam.gserviceaccount.com"
]

# ❌ Avoid: User accounts for production applications
writer_members = [
  "user:developer@company.com"
]
```

### 3. Use Groups for Team Access
```hcl
# ✅ Good: Manage team members through groups
reader_members = ["group:data-analysts@company.com"]

# ❌ Harder to manage: Individual users
reader_members = [
  "user:alice@company.com",
  "user:bob@company.com",
  "user:charlie@company.com"
]
```

### 4. Separate Production and Development
```hcl
# Different buckets and permissions per environment
environment = "production"
admin_members = ["group:platform-prod@company.com"]

# vs

environment = "development"
admin_members = ["group:all-engineers@company.com"]
```

## Troubleshooting

### Access Denied After Granting Permission
IAM changes can take a few minutes to propagate. Wait 2-3 minutes and try again.

### Invalid Member Format
Ensure correct prefix:
```hcl
# ✅ Correct
"serviceAccount:app@project.iam.gserviceaccount.com"

# ❌ Incorrect (missing prefix)
"app@project.iam.gserviceaccount.com"
```

### Cannot Grant Permission to allUsers
The bucket has public access prevention enforced. This is intentional for security. Use IAM members instead.

## Cost Considerations

IAM bindings have no direct cost, but consider:
- **Audit Logging**: Enabling Cloud Audit Logs for IAM changes incurs logging costs
- **IAM Operations**: Frequent permission changes may have minimal API costs

## Next Steps

- See [bucket-with-notifications](../bucket-with-notifications/) for event-driven workflows
- See [multi-bucket](../multi-bucket/) for managing multiple buckets
- Review [IAM Module Documentation](../../modules/gcs-bucket-iam/)

## Learn More

- [GCS IAM Roles](https://cloud.google.com/storage/docs/access-control/iam-roles)
- [IAM Best Practices](https://cloud.google.com/iam/docs/best-practices)
- [Service Account Best Practices](https://cloud.google.com/iam/docs/best-practices-service-accounts)

