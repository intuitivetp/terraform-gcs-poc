variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "labels" {
  description = "Resource labels"
  type        = map(string)
  default     = {}
}

variable "frontend_bucket" {
  description = "Frontend bucket name for event tracking"
  type        = string
}

variable "backend_service" {
  description = "Backend service URL"
  type        = string
}

