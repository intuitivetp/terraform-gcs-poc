# Terraform GCS POC

[![Terraform CI](https://github.com/intuitivetp/terraform-gcs-poc/workflows/Terraform%20CI/badge.svg)](https://github.com/intuitivetp/terraform-gcs-poc/actions)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

A proof-of-concept demonstrating **agentic test creation and validation** for Terraform code managing Google Cloud Storage (GCS) resources. This project showcases automated testing patterns, modular Terraform design, and CI/CD integration for infrastructure as code.

## 📚 Documentation

- **[Confluence Page](https://intuitive-cloud.atlassian.net/wiki/spaces/ape/pages/35454977/Agentic+Test+Creation+and+Validation+of+Terraform+Code+POC)** - Full project context and research
- **[Architecture Overview](#architecture)** - Module structure and design patterns
- **[Contributing Guide](CONTRIBUTING.md)** - Development workflow and standards

## 🎯 Project Goals

1. **Agentic Test Generation**: Demonstrate AI-assisted creation of comprehensive Terratest suites
2. **Infrastructure Validation**: Ensure Terraform modules are production-ready through automated testing
3. **Best Practices**: Showcase modern patterns for GCS bucket management with lifecycle rules, IAM, and notifications

## 🚀 Quick Start

### Prerequisites

- **Terraform** >= 1.0
- **Go** >= 1.21 (for tests)
- **GCP Project** with billing enabled
- **gcloud CLI** configured with appropriate credentials

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/intuitivetp/terraform-gcs-poc.git
   cd terraform-gcs-poc
   ```

2. Configure your GCP project:
   ```bash
   export GOOGLE_PROJECT=your-project-id
   gcloud auth application-default login
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

### Basic Usage

**Deploy infrastructure:**
```bash
terraform plan
terraform apply
```

**Run tests:**
```bash
cd tests
go mod download
go test -v -timeout 30m
```

**Clean up:**
```bash
terraform destroy
```

## 📦 Module Structure

```
.
├── modules/
│   ├── gcs-bucket/              # Core GCS bucket with lifecycle rules
│   ├── gcs-bucket-iam/          # IAM bindings for bucket access
│   └── gcs-bucket-notification/ # Pub/Sub notifications for bucket events
├── tests/                       # Terratest integration tests
├── docs/                        # Detailed documentation
├── examples/                    # Usage examples
└── .github/workflows/           # CI/CD automation
```

### Modules

#### `gcs-bucket`
Creates a GCS bucket with:
- Uniform bucket-level access
- Public access prevention
- Versioning support
- Lifecycle rules (delete old objects, archive versions, abort incomplete uploads)
- Access logging
- Custom labels

**Example:**
```hcl
module "my_bucket" {
  source = "./modules/gcs-bucket"

  project_id         = "my-project"
  bucket_name        = "my-unique-bucket-name"
  location           = "US"
  storage_class      = "STANDARD"
  versioning_enabled = true
  lifecycle_age_days = 30
  
  labels = {
    environment = "production"
    team        = "platform"
  }
}
```

#### `gcs-bucket-iam`
Manages IAM bindings for bucket access control.

**Example:**
```hcl
module "bucket_iam" {
  source = "./modules/gcs-bucket-iam"

  bucket = module.my_bucket.name
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:my-sa@my-project.iam.gserviceaccount.com"
  ]
}
```

#### `gcs-bucket-notification`
Creates Pub/Sub notifications for bucket events.

**Example:**
```hcl
module "bucket_notification" {
  source = "./modules/gcs-bucket-notification"

  bucket       = module.my_bucket.name
  topic        = "projects/my-project/topics/bucket-events"
  event_types  = ["OBJECT_FINALIZE", "OBJECT_DELETE"]
  payload_format = "JSON_API_V1"
}
```

## 🧪 Testing

This project uses [Terratest](https://terratest.gruntwork.io/) for automated infrastructure testing.

### Test Coverage

| Module | Test File | Coverage |
|--------|-----------|----------|
| `gcs-bucket` | `gcs_bucket_test.go` | ✅ Resource creation, lifecycle rules, versioning |
| `gcs-bucket-iam` | `gcs_bucket_iam_test.go` | ✅ IAM bindings |
| `gcs-bucket-notification` | `gcs_bucket_notification_test.go` | ✅ Pub/Sub integration |

### Running Tests

**All tests:**
```bash
cd tests
go test -v -timeout 30m
```

**Specific test:**
```bash
go test -v -run TestGCSBucketCreation -timeout 30m
```

**Parallel execution:**
```bash
go test -v -parallel 3 -timeout 30m
```

### Test Requirements

- Tests run against **real GCP infrastructure**
- Each test creates and destroys resources
- Minimum 80% module coverage
- Both positive and negative test cases
- Unique resource names using random suffixes

## 🏗️ Architecture

### Design Principles

1. **Modularity**: Each module handles a single concern (bucket, IAM, notifications)
2. **Reusability**: Modules are composable and configurable via variables
3. **Security**: Enforces uniform bucket-level access and public access prevention
4. **Best Practices**: Implements lifecycle management, versioning, and logging

### Lifecycle Rules

The `gcs-bucket` module includes three lifecycle rules:

1. **Delete Old Objects**: Removes objects after configured days (default: 30)
2. **Archive Versions**: Moves archived STANDARD objects to ARCHIVE class after 90 days
3. **Abort Incomplete Uploads**: Cleans up incomplete multipart uploads after 7 days

### GCP Project Configuration

- **Project ID**: `devops-sandbox-452616`
- **Project Number**: `209427249385`
- **Primary Region**: `us-central1`
- **Environment**: Sandbox/Testing

## 🔄 CI/CD

GitHub Actions workflows automate:
- **Terraform validation** on every PR
- **Format checking** with `terraform fmt`
- **Security scanning** (planned)
- **Automated test execution** via Terratest
- **Documentation generation** (planned)

See [`.github/workflows/terraform-ci.yml`](.github/workflows/terraform-ci.yml) for details.

## 📖 Additional Documentation

- **[Module Documentation](docs/modules.md)** - Detailed module reference
- **[Testing Guide](docs/testing.md)** - Test writing and best practices
- **[Examples](examples/)** - Common usage patterns
- **[Troubleshooting](docs/troubleshooting.md)** - Common issues and solutions

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guide](CONTRIBUTING.md) for:
- Development workflow
- Coding standards
- Testing requirements
- Commit message conventions
- PR process

## 📋 Roadmap

- [ ] Add OPA policy validation
- [ ] Implement cost estimation in CI
- [ ] Add more lifecycle rule examples
- [ ] Create Terraform Cloud integration
- [ ] Add drift detection automation
- [ ] Implement multi-region examples

## 🔒 Security

- Never commit GCP credentials
- Use service accounts with least privilege
- Enable audit logging for all buckets
- Follow [GCP security best practices](https://cloud.google.com/security/best-practices)

Report security issues to: security@intuitive.com

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Terratest](https://terratest.gruntwork.io/) for testing framework
- [Google Cloud Platform](https://cloud.google.com/) for infrastructure
- The Intuitive Platform Engineering team

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/intuitivetp/terraform-gcs-poc/issues)
- **Confluence**: [Project Page](https://intuitive-cloud.atlassian.net/wiki/spaces/ape/pages/35454977/)
- **Slack**: #platform-engineering

---

**Made with ❤️ by the Intuitive Platform Engineering Team**
