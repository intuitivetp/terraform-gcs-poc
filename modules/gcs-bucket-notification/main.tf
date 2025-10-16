terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_storage_notification" "notification" {
  bucket         = var.bucket_name
  payload_format = var.payload_format
  topic          = var.pubsub_topic
  event_types    = var.event_types

  custom_attributes = var.custom_attributes
}
