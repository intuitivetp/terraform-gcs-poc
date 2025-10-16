/**
 * Storage Module - Document Storage
 */

resource "google_storage_bucket" "documents" {
  name          = "${var.project_id}-${var.environment}-banking-docs"
  location      = var.region
  force_destroy = var.environment != "prod"

  uniform_bucket_level_access = true

  labels = var.labels

  encryption {
    default_kms_key_name = null
  }

  versioning {
    enabled = var.environment == "prod"
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }
}

# Service account for backend to access storage
resource "google_storage_bucket_iam_member" "backend_access" {
  bucket = google_storage_bucket.documents.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.project_id}@appspot.gserviceaccount.com"
}

