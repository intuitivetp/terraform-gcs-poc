/**
 * Analytics Module
 * Provisions BigQuery dataset and Cloud Functions for user behavior tracking
 */

resource "google_bigquery_dataset" "analytics" {
  dataset_id                  = "${var.environment}_analytics"
  friendly_name               = "Banking Analytics"
  description                 = "User behavior and transaction analytics"
  location                    = var.region
  default_table_expiration_ms = 31536000000 # 365 days

  labels = var.labels
}

resource "google_storage_bucket" "analytics_functions" {
  name          = "${var.project_id}-${var.environment}-analytics-functions"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  labels = var.labels
}

resource "google_cloudfunctions2_function" "event_processor" {
  name        = "${var.environment}-analytics-processor"
  location    = var.region
  description = "Processes user events and stores in BigQuery"

  build_config {
    runtime     = "python311"
    entry_point = "process_event"
    source {
      storage_source {
        bucket = google_storage_bucket.analytics_functions.name
        object = "analytics-function.zip"
      }
    }
  }

  service_config {
    max_instance_count = 10
    available_memory   = "256M"
    timeout_seconds    = 60

    environment_variables = {
      DATASET_ID   = google_bigquery_dataset.analytics.dataset_id
      PROJECT_ID   = var.project_id
      FRONTEND_URL = var.frontend_bucket
    }
  }

  labels = var.labels
}

