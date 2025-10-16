terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = var.bucket_name
  role   = var.role
  member = var.member
}
