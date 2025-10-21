# Security Module

This module manages secrets and security configurations for the online banking application using Google Cloud Secret Manager.

## Features

- **Secret Management**: Creates and manages secrets for sensitive data
- **Access Control**: Provisions a service account with appropriate permissions
- **Multiple Secret Types**: Supports database passwords, API keys, JWT signing keys, and encryption keys
- **Automatic Replication**: Secrets are automatically replicated across regions

## Secrets Created

1. **Database Password**: Secure storage for database credentials
2. **API Key**: Third-party integration API keys
3. **JWT Signing Key**: Key for signing JWT tokens
4. **Encryption Key**: Key for encrypting sensitive data at rest

## Usage

```hcl
module "security" {
  source = "./modules/security"

  project_id  = var.project_id
  environment = var.environment
  labels      = local.common_labels
}
```

## Outputs

- `db_password_secret_id`: ID for the database password secret
- `api_key_secret_id`: ID for the API key secret
- `jwt_signing_key_secret_id`: ID for the JWT signing key secret
- `encryption_key_secret_id`: ID for the encryption key secret
- `secrets_accessor_email`: Service account email with secret access
- `secrets_accessor_id`: Unique ID of the service account

## Security Best Practices

- Secrets are created but not populated with values (values must be set separately)
- Service account follows principle of least privilege
- Automatic replication ensures high availability
- All resources are labeled for easy tracking and cost allocation

