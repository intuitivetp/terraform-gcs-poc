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

# Create bucket
module "data_bucket" {
  source = "../../modules/gcs-bucket"

  project_id         = var.project_id
  bucket_name        = "${var.bucket_name_prefix}-${random_id.bucket_suffix.hex}"
  location           = var.location
  storage_class      = "STANDARD"
  versioning_enabled = true
  lifecycle_age_days = 90

  labels = {
    environment = var.environment
    managed_by  = "terraform"
    example     = "bucket-with-iam"
  }
}

# Grant read access to a service account
module "bucket_read_access" {
  source = "../../modules/gcs-bucket-iam"

  bucket  = module.data_bucket.name
  role    = "roles/storage.objectViewer"
  members = var.reader_members
}

# Grant write access to different service accounts
module "bucket_write_access" {
  source = "../../modules/gcs-bucket-iam"

  bucket  = module.data_bucket.name
  role    = "roles/storage.objectCreator"
  members = var.writer_members
}

# Grant admin access for administrators
module "bucket_admin_access" {
  source = "../../modules/gcs-bucket-iam"

  bucket  = module.data_bucket.name
  role    = "roles/storage.objectAdmin"
  members = var.admin_members
}

