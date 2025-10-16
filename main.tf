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

module "test_bucket" {
  source = "./modules/gcs-bucket"

  project_id         = var.project_id
  bucket_name        = "test-bucket-${var.project_id}-${random_id.suffix.hex}"
  location           = "US"
  storage_class      = "STANDARD"
  versioning_enabled = true
  lifecycle_age_days = 30
  log_bucket         = "logs-${var.project_id}"

  labels = {
    environment = "test"
    managed_by  = "terraform"
    purpose     = "poc"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
