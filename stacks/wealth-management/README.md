# Wealth Management Stack

A complete multi-tier application infrastructure demonstrating GCP best practices.

## Architecture

This stack provisions a complete wealth management application with:

- **Frontend**: Static website hosted on GCS with Cloud CDN
- **Backend**: Cloud Run API services with authentication
- **Database**: Cloud SQL PostgreSQL with read replicas
- **Storage**: GCS buckets for document management
- **Security**: IAM policies, encryption, VPC configuration
- **Automation**: GitHub workflow coverage, diagram generation, and self-healing feedback
- **Monitoring**: Cloud Monitoring and Logging

## Components

### Frontend Layer
- GCS bucket for static website hosting
- Cloud CDN for content delivery
- SSL certificates for HTTPS

### Application Layer
- Cloud Run service for API backend
- Service account with minimal permissions
- Environment-specific configurations

### Data Layer
- Cloud SQL PostgreSQL instance
- Automated backups and point-in-time recovery
- Read replicas for scaling

### Storage Layer
- GCS bucket for user documents
- Lifecycle policies for cost optimization
- Encryption at rest

## Usage

```bash
# Initialize
terraform init

# Plan deployment
terraform plan -var="project_id=your-project-id" -var="environment=dev"

# Apply
terraform apply -var="project_id=your-project-id" -var="environment=dev"

# Generate architecture diagram
../../scripts/generate-diagram.sh
```

## Outputs

- `frontend_url`: Public URL for the wealth application
- `api_url`: Backend API endpoint
- `database_connection`: Cloud SQL connection string

## Cost Estimate

Development environment: ~$50-100/month
Production environment: ~$300-500/month (depending on usage)
