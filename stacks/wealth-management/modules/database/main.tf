/**
 * Database Module - Cloud SQL PostgreSQL
 */

terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_id" "db_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "postgres" {
  name             = "${var.environment}-wealth-db-${random_id.db_suffix.hex}"
  database_version = "POSTGRES_15"
  region           = var.region

  deletion_protection = var.environment == "prod"

  settings {
    tier = var.environment == "prod" ? "db-custom-2-7680" : "db-f1-micro"

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = var.environment == "prod"
    }

    ip_configuration {
      ipv4_enabled    = true
      private_network = null

      authorized_networks {
        name  = "allow-all-for-demo"
        value = "0.0.0.0/0"
      }
    }

    database_flags {
      name  = "max_connections"
      value = "100"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
    }
  }
}

resource "google_sql_database" "wealth" {
  name     = "wealth"
  instance = google_sql_database_instance.postgres.name
}

resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "google_sql_user" "wealth_user" {
  name     = "wealth_app"
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password.result
}

