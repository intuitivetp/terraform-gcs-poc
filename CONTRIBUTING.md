# Contributing to terraform-gcs-poc

Thank you for your interest in contributing to this project! This guide will help you get started with contributing to our Terraform GCS POC demonstrating agentic test creation and validation.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)
- [Review Process](#review-process)

## Code of Conduct

### Our Standards

- **Be respectful and inclusive** in all interactions
- **Collaborate constructively** with other contributors
- **Focus on what's best for the project** and the community
- **Accept constructive feedback** gracefully
- **Prioritize security and quality** in all contributions

### Unacceptable Behavior

- Harassment, discriminatory language, or personal attacks
- Publishing others' private information
- Trolling, inflammatory comments, or deliberate disruption
- Other conduct that would be inappropriate in a professional setting

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Terraform** >= 1.0
- **Go** >= 1.21 (for tests)
- **gcloud CLI** configured
- **Git** for version control
- Access to a **GCP project** for testing

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/terraform-gcs-poc.git
   cd terraform-gcs-poc
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/intuitivetp/terraform-gcs-poc.git
   ```

### Setup Development Environment

1. **Configure GCP credentials**:
   ```bash
   gcloud auth application-default login
   export GOOGLE_PROJECT=your-test-project-id
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Install Go dependencies**:
   ```bash
   cd tests
   go mod download
   ```

4. **Verify setup**:
   ```bash
   terraform validate
   go test -v -short
   ```

## Development Workflow

### 1. Create a Feature Branch

```bash
# Sync with upstream
git fetch upstream
git checkout main
git merge upstream/main

# Create feature branch
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

- Follow the [Coding Standards](#coding-standards)
- Write tests for new functionality
- Update documentation as needed
- Keep commits focused and atomic

### 3. Test Your Changes

```bash
# Format Terraform code
terraform fmt -recursive

# Validate configuration
terraform validate

# Run tests
cd tests
go test -v -timeout 30m

# Run specific test
go test -v -run TestName -timeout 30m
```

### 4. Commit Your Changes

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```bash
git add .
git commit -m "feat(module): add lifecycle rule customization"
```

#### Commit Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Formatting, no code change
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

#### Commit Examples

```bash
git commit -m "feat(gcs-bucket): add support for CORS configuration"
git commit -m "fix(tests): resolve bucket naming conflict"
git commit -m "docs(readme): update installation instructions"
git commit -m "test(iam): add test for multiple member bindings"
```

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## Coding Standards

### Terraform Standards

#### File Organization

```
module-name/
├── main.tf         # Main resource definitions
├── variables.tf    # Input variables
├── outputs.tf      # Output values
├── README.md       # Module documentation
└── versions.tf     # Version constraints (optional)
```

#### Formatting

- Use **2-space indentation**
- Run `terraform fmt` before committing
- Keep lines under 120 characters
- Group related resources together

#### Naming Conventions

```hcl
# Resources: descriptive names with context
resource "google_storage_bucket" "data_bucket" { }

# Variables: snake_case
variable "bucket_name" { }
variable "lifecycle_age_days" { }

# Outputs: snake_case
output "bucket_url" { }
```

#### Best Practices

```hcl
# ✅ Good: Version constraints
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# ✅ Good: Descriptive variables with defaults
variable "storage_class" {
  description = "Storage class for the bucket (STANDARD, NEARLINE, COLDLINE, ARCHIVE)"
  type        = string
  default     = "STANDARD"
  
  validation {
    condition     = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "Storage class must be STANDARD, NEARLINE, COLDLINE, or ARCHIVE."
  }
}

# ✅ Good: Security defaults
resource "google_storage_bucket" "bucket" {
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

# ✅ Good: Meaningful labels
labels = {
  environment = var.environment
  managed_by  = "terraform"
  team        = var.team
}
```

### Go/Terratest Standards

#### Test Structure

```go
func TestModuleName_Scenario(t *testing.T) {
    t.Parallel()  // Always enable parallel execution
    
    // Arrange
    uniqueID := random.UniqueId()
    resourceName := fmt.Sprintf("test-%s", strings.ToLower(uniqueID))
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../path/to/module",
        Vars: map[string]interface{}{
            "project_id": gcp.GetGoogleProjectIDFromEnvVar(t),
            "name":       resourceName,
        },
    }
    
    // Cleanup
    defer terraform.Destroy(t, terraformOptions)
    
    // Act
    terraform.InitAndApply(t, terraformOptions)
    
    // Assert
    output := terraform.Output(t, terraformOptions, "output_name")
    assert.Equal(t, expectedValue, output, "Output mismatch")
    
    // Validate actual GCP state
    resource := gcp.GetResource(t, resourceName)
    assert.NotNil(t, resource, "Resource should exist")
}
```

#### Testing Best Practices

- ✅ Use `t.Parallel()` for all tests
- ✅ Always use unique resource names with random suffixes
- ✅ Use `defer terraform.Destroy()` for cleanup
- ✅ Test both Terraform outputs and actual GCP resources
- ✅ Include descriptive assertion messages
- ✅ Test default and custom configurations
- ✅ Set appropriate timeouts (30m for integration tests)

## Testing Guidelines

### Test Coverage Requirements

- **Minimum 80% module coverage**
- **Each module**: At least one integration test
- **Each variable**: Tested with default and custom values
- **Include**: Negative test cases where applicable

### Running Tests

```bash
# All tests
cd tests
go test -v -timeout 30m

# Specific test
go test -v -run TestGCSBucketCreation -timeout 30m

# Parallel execution
go test -v -parallel 3 -timeout 30m

# With coverage
go test -v -cover -timeout 30m
```

### Test Checklist

Before submitting tests:
- [ ] Test name clearly describes scenario
- [ ] Uses `t.Parallel()` for parallel execution
- [ ] Generates unique resource names
- [ ] Uses `defer terraform.Destroy()` for cleanup
- [ ] Validates Terraform outputs
- [ ] Validates actual GCP resource state
- [ ] Includes meaningful assertion messages
- [ ] Has appropriate timeout setting
- [ ] Documents prerequisites

## Documentation

### Module README Requirements

Every module should have a README.md with:

1. **Overview**: What the module does
2. **Features**: Key capabilities
3. **Usage**: Basic and advanced examples
4. **Variables**: Table with descriptions and defaults
5. **Outputs**: Table with descriptions
6. **Best Practices**: Recommendations and tips
7. **Examples**: Real-world usage patterns
8. **Troubleshooting**: Common issues and solutions
9. **References**: Links to related documentation

### Documentation Style

- Use clear, concise language
- Include code examples for clarity
- Use tables for structured information
- Add links to related resources
- Include emoji for visual clarity (✅ ❌ ⚠️)

### Code Comments

```hcl
# Good: Explains WHY
# Archive old versions to reduce storage costs
lifecycle_rule {
  action { type = "SetStorageClass" }
}

# Avoid: States the obvious
# Set storage class to ARCHIVE
lifecycle_rule {
  action { type = "SetStorageClass" }
}
```

## Submitting Changes

### Before Submitting

1. **Run all checks**:
   ```bash
   terraform fmt -recursive
   terraform validate
   cd tests && go test -v -timeout 30m
   ```

2. **Update documentation**:
   - Module README if functionality changed
   - Main README if new module added
   - CHANGELOG if one exists

3. **Verify examples work**:
   ```bash
   cd examples/your-example
   terraform init
   terraform validate
   ```

### Pull Request Guidelines

#### PR Title

Use conventional commit format:
```
feat(gcs-bucket): add CORS configuration support
fix(tests): resolve parallel execution conflicts
docs(readme): update testing instructions
```

#### PR Description Template

```markdown
## Description
Brief description of changes and motivation

## Changes
- Bullet list of specific changes
- Include any breaking changes
- Note any new dependencies

## Testing
- [ ] All existing tests pass
- [ ] New tests added for new functionality
- [ ] Manual testing performed

## Documentation
- [ ] Module README updated
- [ ] Examples updated or added
- [ ] GEMINI.md updated if relevant

## Screenshots/Examples
(If applicable) Include examples of usage or output

## Checklist
- [ ] Code follows project style guidelines
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] Commits follow conventional format
```

### PR Best Practices

- **Keep PRs focused**: One feature or fix per PR
- **Write clear descriptions**: Explain what and why
- **Include tests**: All new code should have tests
- **Update docs**: Keep documentation in sync
- **Respond to feedback**: Address review comments promptly

## Review Process

### What Reviewers Look For

1. **Code Quality**
   - Follows Terraform and Go best practices
   - Proper error handling
   - Security considerations

2. **Testing**
   - Adequate test coverage
   - Tests are well-written and clear
   - All tests pass

3. **Documentation**
   - README updated
   - Code comments where needed
   - Examples work correctly

4. **Style**
   - Terraform formatted correctly
   - Conventional commits used
   - Clear PR description

### Review Timeline

- Initial review: Within 2-3 business days
- Follow-up reviews: Within 1-2 business days
- Merge: After approval and CI passes

### Addressing Review Feedback

```bash
# Make requested changes
git add .
git commit -m "fix: address review feedback"
git push origin feature/your-feature

# If significant changes, add to existing commit
git add .
git commit --amend --no-edit
git push origin feature/your-feature --force-with-lease
```

## Additional Resources

### Documentation
- [Project README](README.md)
- [Testing Guide](docs/testing.md)
- [Troubleshooting Guide](docs/troubleshooting.md)
- [Module Documentation](modules/)

### External Resources
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)
- [Terratest Documentation](https://terratest.gruntwork.io/docs/)
- [GCP Documentation](https://cloud.google.com/storage/docs)
- [Conventional Commits](https://www.conventionalcommits.org/)

### Getting Help

- **GitHub Issues**: Report bugs or request features
- **Slack**: #platform-engineering for questions
- **Confluence**: Project documentation and context

## Recognition

Contributors will be:
- Listed in project documentation
- Credited in release notes
- Acknowledged in the community

Thank you for contributing to terraform-gcs-poc! 🎉

---

**Questions?** Feel free to open an issue or reach out on Slack (#platform-engineering).

