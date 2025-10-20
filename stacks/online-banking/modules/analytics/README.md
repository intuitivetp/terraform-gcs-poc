# Analytics Module

This module provisions analytics infrastructure for user behavior tracking in the online banking application.

## Features

- **BigQuery Dataset**: Centralized data warehouse for analytics data
- **Cloud Functions**: Event processing pipeline for real-time user behavior tracking
- **Storage Integration**: Connects to frontend bucket for event collection
- **API Integration**: Links with backend service for transaction analytics

## Resources Created

- `google_bigquery_dataset.analytics`: BigQuery dataset for analytics storage
- `google_storage_bucket.analytics_functions`: Storage bucket for Cloud Functions code
- `google_cloudfunctions2_function.event_processor`: Cloud Function for event processing

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| project_id | GCP Project ID | string | yes |
| environment | Environment name (dev, staging, prod) | string | yes |
| region | GCP region | string | yes |
| labels | Resource labels | map(string) | no |
| frontend_bucket | Frontend bucket name for event tracking | string | yes |
| backend_service | Backend service URL | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| dataset_id | BigQuery dataset ID |
| function_url | Analytics function URL |

## Usage

```hcl
module "analytics" {
  source = "./modules/analytics"

  project_id  = var.project_id
  environment = var.environment
  region      = var.region
  labels      = local.common_labels

  frontend_bucket = module.frontend.bucket_name
  backend_service = module.backend.service_url

  depends_on = [google_project_service.required_apis]
}
```

## Architecture

The analytics module creates a real-time event processing pipeline:

1. User events are captured from the frontend application
2. Events are sent to the Cloud Function endpoint
3. The function validates and processes events
4. Processed data is stored in BigQuery tables
5. Data is available for analysis and reporting

## Data Retention

- BigQuery tables have a default expiration of 365 days
- Adjust `default_table_expiration_ms` in main.tf to modify retention period

## Security Considerations

- Function runs with minimal required permissions
- Data is encrypted at rest in BigQuery
- Access to analytics data follows IAM best practices

