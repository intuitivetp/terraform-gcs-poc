output "member" {
  description = "IAM member added"
  value       = google_storage_bucket_iam_member.member.member
}

output "role" {
  description = "IAM role assigned"
  value       = google_storage_bucket_iam_member.member.role
}
