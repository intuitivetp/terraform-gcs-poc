output "bucket_name" {
  description = "Name of the created bucket"
  value       = module.simple_bucket.name
}

output "bucket_url" {
  description = "GS URL of the bucket"
  value       = module.simple_bucket.url
}

output "bucket_self_link" {
  description = "Self link to the bucket"
  value       = module.simple_bucket.self_link
}

