output "bucket_name" {
  description = "Name of the created test bucket"
  value       = module.test_bucket.bucket_name
}

output "bucket_url" {
  description = "URL of the test bucket"
  value       = module.test_bucket.bucket_url
}
