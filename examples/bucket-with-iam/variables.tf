variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "bucket_name_prefix" {
  description = "Prefix for bucket name"
  type        = string
  default     = "data-bucket"
}

variable "location" {
  description = "Bucket location"
  type        = string
  default     = "US"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "development"
}

variable "reader_members" {
  description = "List of members who can read from the bucket"
  type        = list(string)
  default     = []
}

variable "writer_members" {
  description = "List of members who can write to the bucket"
  type        = list(string)
  default     = []
}

variable "admin_members" {
  description = "List of members who have full control of bucket objects"
  type        = list(string)
  default     = []
}

