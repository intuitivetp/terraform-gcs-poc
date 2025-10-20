output "instance_name" {
  description = "Database instance name"
  value       = google_sql_database_instance.postgres.name
}

output "connection_name" {
  description = "Database connection name"
  value       = google_sql_database_instance.postgres.connection_name
}

output "database_name" {
  description = "Database name"
  value       = google_sql_database.wealth.name
}

output "instance_ip" {
  description = "Database instance IP"
  value       = google_sql_database_instance.postgres.ip_address[0].ip_address
}

