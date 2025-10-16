/**
 * Online Banking Stack - Main Configuration
 * 
 * This stack provisions a complete multi-tier banking application
 * demonstrating infrastructure patterns for production workloads.
 */

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Local variables for resource naming
locals {
  app_name = "online-banking"
  common_labels = {
    application = local.app_name
    environment = var.environment
    managed_by  = "terraform"
    stack       = "online-banking"
  }
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "storage.googleapis.com",
    "run.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
  ])
  
  service            = each.value
  disable_on_destroy = false
}

# Frontend: Static website hosting
module "frontend" {
  source = "./modules/frontend"
  
  project_id   = var.project_id
  environment  = var.environment
  region       = var.region
  labels       = local.common_labels
  
  depends_on = [google_project_service.required_apis]
}

# Backend: API services
module "backend" {
  source = "./modules/backend"
  
  project_id   = var.project_id
  environment  = var.environment
  region       = var.region
  labels       = local.common_labels
  
  database_connection_name = module.database.connection_name
  
  depends_on = [google_project_service.required_apis]
}

# Database: Cloud SQL PostgreSQL
module "database" {
  source = "./modules/database"
  
  project_id   = var.project_id
  environment  = var.environment
  region       = var.region
  labels       = local.common_labels
  
  depends_on = [google_project_service.required_apis]
}

# Storage: Document management
module "storage" {
  source = "./modules/storage"
  
  project_id   = var.project_id
  environment  = var.environment
  region       = var.region
  labels       = local.common_labels
  
  depends_on = [google_project_service.required_apis]
}

# Monitoring and logging configuration
module "monitoring" {
  source = "./modules/monitoring"
  
  project_id   = var.project_id
  environment  = var.environment
  labels       = local.common_labels
  
  depends_on = [google_project_service.required_apis]
}

