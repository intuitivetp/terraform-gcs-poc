# Examples

This directory contains practical examples demonstrating various usage patterns for the terraform-gcs-poc modules.

## Available Examples

### [Simple Bucket](simple-bucket/)
Basic GCS bucket with minimal configuration - perfect for getting started.

**Use Case:** Development environments, temporary storage

### [Versioned Bucket](versioned-bucket/)
Bucket with versioning enabled and lifecycle rules for data retention.

**Use Case:** Production data storage, compliance requirements

### [Bucket with IAM](bucket-with-iam/)
Complete example showing bucket creation with IAM role assignments.

**Use Case:** Application access control, team permissions

### [Bucket with Notifications](bucket-with-notifications/)
Event-driven setup with Pub/Sub notifications for bucket events.

**Use Case:** ETL pipelines, real-time processing

### [Multi-Bucket](multi-bucket/)
Multiple buckets with different configurations in a single deployment.

**Use Case:** Multi-environment setups, data segregation

## Using the Examples

### Prerequisites
- Terraform >= 1.0
- GCP project with billing enabled
- Appropriate GCP permissions

### Quick Start

1. **Navigate to an example:**
   ```bash
   cd examples/simple-bucket
   ```

2. **Create a `terraform.tfvars` file:**
   ```hcl
   project_id = "your-gcp-project-id"
   region     = "us-central1"
   ```

3. **Initialize and apply:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Clean up when done:**
   ```bash
   terraform destroy
   ```

## Example Structure

Each example directory contains:
- `main.tf` - Main Terraform configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `README.md` - Example-specific documentation
- `terraform.tfvars.example` - Sample variable values

## Customization

All examples use variables for easy customization. Copy `terraform.tfvars.example` to `terraform.tfvars` and modify values:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

## Best Practices Demonstrated

- ✅ Use of random suffixes for unique bucket names
- ✅ Proper resource labeling and tagging
- ✅ Security best practices (uniform bucket access, public access prevention)
- ✅ Lifecycle management for cost optimization
- ✅ Modular, reusable code patterns

## Testing Examples

To test examples without applying:

```bash
cd examples/simple-bucket
terraform init
terraform validate
terraform plan
```

## Contributing Examples

Have a useful pattern to share? Contribute a new example:

1. Create a new directory under `examples/`
2. Follow the structure of existing examples
3. Include comprehensive README with use case and instructions
4. Test thoroughly before submitting PR

## Support

- For example-specific questions, see the README in each example directory
- For general questions, see the main [project README](../README.md)
- Report issues on [GitHub](https://github.com/intuitivetp/terraform-gcs-poc/issues)

