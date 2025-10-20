output "dashboard_url" {
  description = "Monitoring dashboard URL"
  value       = "https://console.cloud.google.com/monitoring/dashboards/custom/${google_monitoring_dashboard.wealth_dashboard.id}"
}

output "log_sink_name" {
  description = "Log sink name"
  value       = google_logging_project_sink.wealth_logs.name
}

