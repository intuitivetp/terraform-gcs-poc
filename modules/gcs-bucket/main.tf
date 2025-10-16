# Provider configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# GCS Bucket resource
resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  location      = var.location
  storage_class = var.storage_class
  project       = var.project_id

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  logging {
    log_bucket = var.log_bucket
  }

  versioning {
    enabled = var.versioning_enabled
  }

  # Basic lifecycle rule (existing)
  lifecycle_rule {
    condition {
      age = var.lifecycle_age_days
    }
    action {
      type = "Delete"
    }
  }

  # Advanced lifecycle rule 1: Archive old versions
  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
    condition {
      age                   = 90
      with_state            = "ARCHIVED"
      matches_storage_class = ["STANDARD"]
    }
  }

  # Advanced lifecycle rule 2: Delete incomplete uploads
  lifecycle_rule {
    action {
      type = "AbortIncompleteMultipartUpload"
    }
    condition {
      age = 7
    }
  }

  labels = var.labels
}