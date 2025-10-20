output "service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_service.api.name
}

output "service_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_service.api.status[0].url
}

output "service_account_email" {
  description = "Service account email"
  value       = google_service_account.backend.email
}

