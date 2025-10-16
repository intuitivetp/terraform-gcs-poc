/**
 * Monitoring Module - Cloud Monitoring and Logging
 */

# Create a monitoring dashboard
resource "google_monitoring_dashboard" "banking_dashboard" {
  dashboard_json = jsonencode({
    displayName = "${var.environment}-banking-dashboard"
    mosaicLayout = {
      columns = 12
      tiles = [
        {
          width  = 6
          height = 4
          widget = {
            title = "Frontend Bucket Requests"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"gcs_bucket\" AND metric.type=\"storage.googleapis.com/api/request_count\""
                  }
                }
              }]
            }
          }
        },
        {
          width  = 6
          height = 4
          widget = {
            title = "Cloud Run Request Count"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_count\""
                  }
                }
              }]
            }
          }
        },
        {
          width  = 6
          height = 4
          widget = {
            title = "Database Connections"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloudsql_database\" AND metric.type=\"cloudsql.googleapis.com/database/postgresql/num_backends\""
                  }
                }
              }]
            }
          }
        }
      ]
    }
  })
}

# Log sink for application logs
resource "google_logging_project_sink" "banking_logs" {
  name        = "${var.environment}-banking-logs-sink"
  destination = "logging.googleapis.com/projects/${var.project_id}/locations/global/buckets/_Default"
  filter      = "labels.application=\"online-banking\" AND labels.environment=\"${var.environment}\""

  unique_writer_identity = true
}

