output "bucket_name" {
  description = "Document storage bucket name"
  value       = google_storage_bucket.documents.name
}

output "bucket_url" {
  description = "Document storage bucket URL"
  value       = google_storage_bucket.documents.url
}

