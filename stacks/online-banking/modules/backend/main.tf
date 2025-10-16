/**
 * Backend Module - Cloud Run API Service
 */

resource "google_service_account" "backend" {
  account_id   = "${var.environment}-banking-api"
  display_name = "Banking API Service Account"
  description  = "Service account for ${var.environment} banking API"
}

resource "google_cloud_run_service" "api" {
  name     = "${var.environment}-banking-api"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.backend.email

      containers {
        image = "gcr.io/cloudrun/hello" # Placeholder image

        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }

        env {
          name  = "DATABASE_CONNECTION_NAME"
          value = var.database_connection_name
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
      }
    }

    metadata {
      labels = var.labels
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "10"
        "run.googleapis.com/cloudsql-instances" = var.database_connection_name
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Allow public access (for demo purposes)
resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.api.name
  location = google_cloud_run_service.api.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Grant SQL client permissions
resource "google_project_iam_member" "sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend.email}"
}

