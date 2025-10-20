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

output "stack_metadata" {
  description = "Metadata about the deployed stack"
  value = {
    stack_name  = "wealth-management"
    environment = var.environment
    region      = var.region
    deployed_at = timestamp()
  }
}

