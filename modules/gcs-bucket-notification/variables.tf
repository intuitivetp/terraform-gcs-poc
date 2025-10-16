variable "bucket_name" {
  description = "Name of the GCS bucket"
  type        = string
}

variable "payload_format" {
  description = "Notification payload format"
  type        = string
  default     = "JSON_API_V1"
}

variable "pubsub_topic" {
  description = "Pub/Sub topic for notifications"
  type        = string
}

variable "event_types" {
  description = "Event types to trigger notifications"
  type        = list(string)
  default     = ["OBJECT_FINALIZE", "OBJECT_DELETE"]
}

variable "custom_attributes" {
  description = "Custom attributes for notifications"
  type        = map(string)
  default     = {}
}
