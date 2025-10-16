# Simple Bucket Example

This example demonstrates the most basic usage of the `gcs-bucket` module - creating a single bucket with minimal configuration.

## What This Creates

- One GCS bucket in the specified location
- Uniform bucket-level access enabled
- Public access prevention enforced
- Basic lifecycle rule (delete objects after 7 days)
- Development environment labels

## Use Cases

- Quick prototyping and development
- Temporary data storage
- Learning and experimentation
- CI/CD artifact storage

## Usage

### 1. Configure Variables

Create a `terraform.tfvars` file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
project_id         = "my-dev-project"
region             = "us-central1"
bucket_name_prefix = "my-simple-bucket"
location           = "US"
```

### 2. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 3. Verify

```bash
# List buckets
gsutil ls

# View bucket details
gsutil ls -L gs://$(terraform output -raw bucket_name)
```

### 4. Test Upload

```bash
# Create test file
echo "Hello, World!" > test.txt

# Upload to bucket
gsutil cp test.txt gs://$(terraform output -raw bucket_name)/

# Verify
gsutil ls gs://$(terraform output -raw bucket_name)/
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
| `region` | GCP region | `us-central1` | No |
| `bucket_name_prefix` | Bucket name prefix | `simple-bucket` | No |
| `location` | Bucket location | `US` | No |

### Outputs

| Output | Description |
|--------|-------------|
| `bucket_name` | The name of the created bucket |
| `bucket_url` | GS URL (gs://...) |
| `bucket_self_link` | Full resource link |

## Features

### Lifecycle Management
Objects are automatically deleted after **7 days** - perfect for temporary data.

To change this, modify `lifecycle_age_days` in `main.tf`:
```hcl
lifecycle_age_days = 30  # Keep for 30 days instead
```

### Security
- ✅ Uniform bucket-level access (no ACLs)
- ✅ Public access prevention enforced
- ✅ HTTPS only (by default)

### Cost Optimization
- Uses **STANDARD** storage class
- 7-day lifecycle rule prevents data accumulation
- Single region for lower costs (if using regional location)

## Customization Examples

### Use Regional Location

```hcl
location = "us-central1"  # Specific region instead of multi-region
```

### Keep Data Longer

```hcl
lifecycle_age_days = 90  # Keep for 3 months
```

### Add Custom Labels

```hcl
labels = {
  environment = "development"
  managed_by  = "terraform"
  team        = "engineering"
  cost_center = "dev-ops"
}
```

## Next Steps

- See [versioned-bucket](../versioned-bucket/) for production-ready configuration
- See [bucket-with-iam](../bucket-with-iam/) to grant access to users/services
- See [bucket-with-notifications](../bucket-with-notifications/) for event-driven workflows

## Troubleshooting

### Bucket name already exists
The random suffix should prevent this, but if it happens:
```bash
terraform destroy
terraform apply  # Will generate a new random suffix
```

### Permission denied
Ensure you have the `roles/storage.admin` role:
```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="user:YOUR_EMAIL" \
  --role="roles/storage.admin"
```

## Cost Estimate

Approximate monthly costs (as of 2025):
- **Storage**: ~$0.02 per GB (STANDARD class in US multi-region)
- **Operations**: First 50,000 Class A ops free, then ~$0.05 per 10,000 ops
- **Data egress**: ~$0.12 per GB (within same region: free)

**Example:** 10 GB storage + 1,000 ops = **~$0.20/month**

## Learn More

- [GCS Bucket Module Documentation](../../modules/gcs-bucket/)
- [Main Project README](../../README.md)
- [GCS Pricing](https://cloud.google.com/storage/pricing)

