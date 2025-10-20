output "bucket_name" {
  description = "Frontend bucket name"
  value       = google_storage_bucket.frontend.name
}

output "bucket_url" {
  description = "Frontend bucket URL"
  value       = google_storage_bucket.frontend.url
}

output "website_url" {
  description = "Public website URL"
  value       = "https://storage.googleapis.com/${google_storage_bucket.frontend.name}/index.html"
}

