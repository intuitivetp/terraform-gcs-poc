variable "bucket_name" {
  description = "Name of the GCS bucket"
  type        = string
}

variable "role" {
  description = "IAM role to assign"
  type        = string
  default     = "roles/storage.objectViewer"
}

variable "member" {
  description = "IAM member (user, serviceAccount, group, etc.)"
  type        = string
}
