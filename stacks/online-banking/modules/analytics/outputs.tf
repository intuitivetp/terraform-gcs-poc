output "dataset_id" {
  description = "BigQuery dataset ID"
  value       = google_bigquery_dataset.analytics.dataset_id
}

output "function_url" {
  description = "Analytics function URL"
  value       = google_cloudfunctions2_function.event_processor.service_config[0].uri
}

