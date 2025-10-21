output "frontend_url" {
  description = "URL for the frontend application"
  value       = module.frontend.website_url
}

output "frontend_bucket" {
  description = "Frontend GCS bucket name"
  value       = module.frontend.bucket_name
}

output "api_url" {
  description = "Backend API endpoint"
  value       = module.backend.service_url
}

output "api_service_name" {
  description = "Cloud Run service name"
  value       = module.backend.service_name
}

output "database_connection_name" {
  description = "Cloud SQL connection name"
  value       = module.database.connection_name
}

output "database_instance_name" {
  description = "Cloud SQL instance name"
  value       = module.database.instance_name
}

output "storage_bucket" {
  description = "Document storage bucket name"
  value       = module.storage.bucket_name
}

output "monitoring_dashboard_url" {
  description = "Cloud Monitoring dashboard URL"
  value       = module.monitoring.dashboard_url
}

output "analytics_dataset_id" {
  description = "BigQuery analytics dataset ID"
  value       = module.analytics.dataset_id
}

output "analytics_function_url" {
  description = "Analytics event processor function URL"
  value       = module.analytics.function_url
}

output "secrets_accessor_email" {
  description = "Service account email for accessing secrets"
  value       = module.security.secrets_accessor_email
}

output "db_password_secret_id" {
  description = "ID of the database password secret in Secret Manager"
  value       = module.security.db_password_secret_id
}

output "api_key_secret_id" {
  description = "ID of the API key secret in Secret Manager"
  value       = module.security.api_key_secret_id
}

output "stack_metadata" {
  description = "Metadata about the deployed stack"
  value = {
    stack_name  = "online-banking"
    environment = var.environment
    region      = var.region
    deployed_at = timestamp()
  }
}
