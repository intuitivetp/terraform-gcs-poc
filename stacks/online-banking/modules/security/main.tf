/**
 * Security Module - Secret Management
 * 
 * Manages secrets for the online banking application using
 * Google Cloud Secret Manager for secure credential storage.
 */

# Enable Secret Manager API
resource "google_project_service" "secretmanager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# Database password secret
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password-${var.environment}"
  
  labels = var.labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

# API key secret for third-party integrations
resource "google_secret_manager_secret" "api_key" {
  secret_id = "api-key-${var.environment}"
  
  labels = var.labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

# JWT signing key secret
resource "google_secret_manager_secret" "jwt_signing_key" {
  secret_id = "jwt-signing-key-${var.environment}"
  
  labels = var.labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

# Encryption key for sensitive data
resource "google_secret_manager_secret" "encryption_key" {
  secret_id = "encryption-key-${var.environment}"
  
  labels = var.labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

# Service account for backend to access secrets
resource "google_service_account" "secrets_accessor" {
  account_id   = "secrets-accessor-${var.environment}"
  display_name = "Secrets Accessor for ${var.environment}"
  description  = "Service account for accessing secrets in ${var.environment}"
}

# Grant secret accessor role to service account
resource "google_secret_manager_secret_iam_member" "db_password_access" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.secrets_accessor.email}"
}

resource "google_secret_manager_secret_iam_member" "api_key_access" {
  secret_id = google_secret_manager_secret.api_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.secrets_accessor.email}"
}

resource "google_secret_manager_secret_iam_member" "jwt_key_access" {
  secret_id = google_secret_manager_secret.jwt_signing_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.secrets_accessor.email}"
}

resource "google_secret_manager_secret_iam_member" "encryption_key_access" {
  secret_id = google_secret_manager_secret.encryption_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.secrets_accessor.email}"
}

