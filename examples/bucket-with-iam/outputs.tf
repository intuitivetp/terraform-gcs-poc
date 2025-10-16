output "bucket_name" {
  description = "Name of the created bucket"
  value       = module.data_bucket.name
}

output "bucket_url" {
  description = "GS URL of the bucket"
  value       = module.data_bucket.url
}

output "reader_binding" {
  description = "IAM binding for readers"
  value       = module.bucket_read_access.binding
  sensitive   = true
}

output "writer_binding" {
  description = "IAM binding for writers"
  value       = module.bucket_write_access.binding
  sensitive   = true
}

output "admin_binding" {
  description = "IAM binding for admins"
  value       = module.bucket_admin_access.binding
  sensitive   = true
}

