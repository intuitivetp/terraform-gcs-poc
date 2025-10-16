terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Generate random suffix for unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Create a simple GCS bucket
module "simple_bucket" {
  source = "../../modules/gcs-bucket"

  project_id         = var.project_id
  bucket_name        = "${var.bucket_name_prefix}-${random_id.bucket_suffix.hex}"
  location           = var.location
  storage_class      = "STANDARD"
  versioning_enabled = false
  lifecycle_age_days = 7

  labels = {
    environment = "development"
    managed_by  = "terraform"
    example     = "simple-bucket"
  }
}

