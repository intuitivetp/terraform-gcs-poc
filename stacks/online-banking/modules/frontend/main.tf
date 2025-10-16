/**
 * Frontend Module - Static Website Hosting
 */

resource "google_storage_bucket" "frontend" {
  name          = "${var.project_id}-${var.environment}-banking-frontend"
  location      = var.region
  force_destroy = var.environment != "prod"
  
  uniform_bucket_level_access = true
  
  labels = var.labels
  
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.frontend.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Sample index.html
resource "google_storage_bucket_object" "index" {
  name    = "index.html"
  bucket  = google_storage_bucket.frontend.name
  content = <<-EOT
    <!DOCTYPE html>
    <html>
      <head>
        <title>Online Banking - ${var.environment}</title>
        <style>
          body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
          .header { background: #4285f4; color: white; padding: 20px; border-radius: 5px; }
          .content { margin-top: 20px; }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>🏦 Online Banking Portal</h1>
          <p>Environment: ${upper(var.environment)}</p>
        </div>
        <div class="content">
          <h2>Welcome to Online Banking</h2>
          <p>This is a demo banking application deployed on GCP.</p>
          <p><strong>Architecture:</strong></p>
          <ul>
            <li>Frontend: GCS Static Hosting</li>
            <li>Backend: Cloud Run API</li>
            <li>Database: Cloud SQL PostgreSQL</li>
            <li>Storage: GCS Document Storage</li>
          </ul>
        </div>
      </body>
    </html>
  EOT
  
  content_type = "text/html"
}

