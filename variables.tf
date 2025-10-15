variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "devops-sandbox-452616"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Optional custom bucket name. If not provided, will be auto-generated."
  type        = string
  default     = null
}
