output "db_password_secret_id" {
  description = "The ID of the database password secret"
  value       = google_secret_manager_secret.db_password.secret_id
}

output "api_key_secret_id" {
  description = "The ID of the API key secret"
  value       = google_secret_manager_secret.api_key.secret_id
}

output "jwt_signing_key_secret_id" {
  description = "The ID of the JWT signing key secret"
  value       = google_secret_manager_secret.jwt_signing_key.secret_id
}

output "encryption_key_secret_id" {
  description = "The ID of the encryption key secret"
  value       = google_secret_manager_secret.encryption_key.secret_id
}

output "secrets_accessor_email" {
  description = "Email of the service account with access to secrets"
  value       = google_service_account.secrets_accessor.email
}

output "secrets_accessor_id" {
  description = "The unique ID of the secrets accessor service account"
  value       = google_service_account.secrets_accessor.unique_id
}

