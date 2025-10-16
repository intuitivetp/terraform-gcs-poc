# Advanced lifecycle rules
resource "google_storage_bucket_lifecycle_rule" "archive_old_versions" {
  bucket = google_storage_bucket.bucket.name

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

resource "google_storage_bucket_lifecycle_rule" "delete_incomplete_uploads" {
  bucket = google_storage_bucket.bucket.name

  action {
    type = "AbortIncompleteMultipartUpload"
  }

  condition {
    age = 7
  }
}


