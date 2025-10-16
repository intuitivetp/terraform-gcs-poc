# AI Agent Instructions for terraform-gcs-poc

## Project Context

This is a proof-of-concept demonstrating **agentic test creation and validation** for Terraform infrastructure code. The project showcases AI-assisted development patterns for Google Cloud Storage (GCS) bucket management using Terraform and Terratest.

### Key Objectives
1. Demonstrate AI-generated comprehensive Terratest suites
2. Validate Terraform modules against production-ready standards
3. Showcase modern GCS management patterns (lifecycle rules, IAM, notifications)
4. Establish CI/CD automation for infrastructure testing

### Project Links
- **Confluence**: https://intuitive-cloud.atlassian.net/wiki/spaces/ape/pages/35454977/Agentic+Test+Creation+and+Validation+of+Terraform+Code+POC
- **Repository**: https://github.com/intuitivetp/terraform-gcs-poc

## Repository Structure

```
.
├── modules/                    # Reusable Terraform modules
│   ├── gcs-bucket/            # Core bucket with lifecycle rules
│   ├── gcs-bucket-iam/        # IAM access control
│   └── gcs-bucket-notification/  # Pub/Sub event notifications
├── tests/                     # Terratest integration tests
├── docs/                      # Comprehensive documentation
│   ├── testing.md            # Testing guide and best practices
│   └── troubleshooting.md    # Common issues and solutions
├── examples/                  # Usage examples for different scenarios
│   ├── simple-bucket/        # Basic bucket creation
│   ├── bucket-with-iam/      # Bucket with access control
│   └── ...
└── .github/workflows/        # CI/CD automation
```

## Code Standards

### Terraform Standards

#### Naming Conventions
- **Resources**: Use descriptive names with context (e.g., `google_storage_bucket.data_bucket`)
- **Variables**: Use snake_case (e.g., `bucket_name`, `lifecycle_age_days`)
- **Modules**: Use kebab-case for directories (e.g., `gcs-bucket-iam`)

#### Best Practices
- **Version constraints**: Always pin Terraform and provider versions
  ```hcl
  terraform {
    required_version = ">= 1.0"
    required_providers {
      google = {
        source  = "hashicorp/google"
        version = "~> 5.0"
      }
    }
  }
  ```

- **Security defaults**:
  - Enable `uniform_bucket_level_access = true`
  - Set `public_access_prevention = "enforced"`
  - Use lifecycle rules for data management

- **Resource organization**:
  - Group related resources in modules
  - Use meaningful labels for all resources
  - Include appropriate outputs

#### Formatting
- Run `terraform fmt` before committing
- Use 2-space indentation
- Follow [Terraform Style Guide](https://developer.hashicorp.com/terraform/language/syntax/style)

### Terratest Standards

#### Test Structure
```go
func TestResourceName_Scenario(t *testing.T) {
    t.Parallel()  // Enable parallel execution
    
    // Arrange: Setup unique test data
    uniqueID := random.UniqueId()
    resourceName := fmt.Sprintf("test-%s", strings.ToLower(uniqueID))
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../path/to/module",
        Vars: map[string]interface{}{
            "required_var": "value",
        },
    }
    
    // Cleanup
    defer terraform.Destroy(t, terraformOptions)
    
    // Act: Apply Terraform
    terraform.InitAndApply(t, terraformOptions)
    
    // Assert: Validate outputs and resources
    output := terraform.Output(t, terraformOptions, "output_name")
    assert.Equal(t, expectedValue, output)
    
    // Validate actual GCP resource state
    resource := gcp.GetResource(t, resourceName)
    assert.NotNil(t, resource)
}
```

#### Testing Requirements
- **Minimum 80% module coverage**
- **Each module**: At least one integration test
- **Unique naming**: Always use random suffixes for resource names
- **Parallel execution**: Use `t.Parallel()` for faster test runs
- **Cleanup**: Always use `defer terraform.Destroy()`
- **Real validation**: Test both Terraform outputs AND actual GCP resource state
- **Meaningful assertions**: Include descriptive failure messages

#### Naming Conventions
- Test functions: `Test<Module><Scenario>` (e.g., `TestGCSBucketCreationWithVersioning`)
- Test files: `<module>_test.go` (e.g., `gcs_bucket_test.go`)

## GCP Environment

### Project Configuration
- **Project ID**: `devops-sandbox-452616`
- **Project Number**: `209427249385`
- **Primary Region**: `us-central1`
- **Environment**: Sandbox/Testing

### Security Requirements
- Use service accounts with least privilege
- Enable audit logging for all resources
- Follow principle of least privilege for IAM
- Never commit credentials or sensitive data

### Resource Naming
- Bucket names must be globally unique
- Use random suffixes: `bucket-name-${random_id.suffix.hex}`
- Include environment labels: `environment = "development"`
- Tag with management info: `managed_by = "terraform"`

## AI Agent Guidelines

### When Generating Tests

1. **Analyze existing structure**
   - Review `./modules/` to understand module interfaces
   - Check `./tests/` to avoid duplication
   - Understand module variables and outputs

2. **Generate comprehensive coverage**
   - Test all configurable parameters
   - Include both default and custom configurations
   - Test edge cases and failure scenarios
   - Validate lifecycle rules and security settings

3. **Ensure uniqueness**
   - Use `random.UniqueId()` for resource names
   - Avoid hardcoded names that cause conflicts
   - Consider parallel test execution implications

4. **Add documentation**
   - Include comments explaining test purpose
   - Document any prerequisites or setup requirements
   - Explain expected outcomes

### When Fixing Failures

1. **Root cause analysis**
   - Read full error logs carefully
   - Identify if issue is in Terraform code or test code
   - Check for state conflicts or permission issues

2. **Fix causes, not symptoms**
   - Address underlying problems
   - Don't add workarounds unless necessary
   - Ensure fix doesn't break other tests

3. **Document changes**
   - Add comments explaining the fix
   - Update relevant documentation
   - Include reasoning in commit messages

### When Reviewing PRs

1. **Code quality**
   - Verify Terraform formatting (`terraform fmt`)
   - Check for security best practices
   - Ensure proper resource labeling

2. **Test coverage**
   - Confirm new modules have tests
   - Verify tests use parallel execution
   - Check for proper cleanup (defer statements)

3. **Documentation**
   - Ensure README files are updated
   - Verify examples are working
   - Check that new features are documented

## Workflow Patterns

### Adding a New Module

1. Create module directory under `modules/`
2. Implement `main.tf`, `variables.tf`, `outputs.tf`
3. Add module README with examples
4. Create comprehensive tests in `tests/`
5. Add usage example in `examples/`
6. Update main README with module reference

### Adding a New Feature

1. Update module code
2. Add or update tests for the feature
3. Verify all existing tests still pass
4. Update module README
5. Add example if appropriate
6. Update CHANGELOG (if exists)

### Debugging Test Failures

1. **Local testing**:
   ```bash
   cd tests
   TF_LOG=DEBUG go test -v -run TestName -timeout 30m
   ```

2. **Check GCP state**:
   ```bash
   gcloud storage buckets list
   gcloud storage buckets describe gs://bucket-name
   ```

3. **Manual cleanup if needed**:
   ```bash
   terraform destroy -auto-approve
   gsutil -m rm -r gs://test-bucket-*
   ```

## Common Tasks

### Generate Tests for New Module

**Prompt Example**:
```
Generate comprehensive Terratest tests for the gcs-bucket module.
Include tests for:
- Default configuration
- Custom lifecycle rules
- Versioning enabled/disabled
- Different storage classes
- Label validation

Ensure tests:
- Use unique resource names
- Run in parallel
- Validate both Terraform outputs and actual GCP resources
- Include proper cleanup
```

### Fix Test Failures

**Prompt Example**:
```
The TestGCSBucketCreation test is failing with error:
[paste error message]

Please analyze the root cause and fix it. Consider:
- Is it a Terraform configuration issue?
- Is it a test code issue?
- Is it a GCP permission or quota issue?

Fix the underlying problem and explain your reasoning.
```

### Review Infrastructure Code

**Prompt Example**:
```
Review this Terraform module for:
1. Security best practices (uniform access, public access prevention)
2. Resource labeling and organization
3. Lifecycle management appropriateness
4. Documentation completeness
5. Test coverage

Suggest improvements with examples.
```

## CI/CD Integration

### GitHub Actions Workflows

The project uses automated workflows for:
- **Terraform validation**: Format checking, syntax validation
- **Test execution**: Automated Terratest runs
- **PR reviews**: Automated code review assistance

### Local Pre-commit Checks

Before committing:
```bash
# Format Terraform code
terraform fmt -recursive

# Validate configuration
terraform validate

# Run tests
cd tests && go test -v -timeout 30m
```

## Documentation Standards

### Module README Requirements
- Overview and features
- Usage examples (basic and advanced)
- Variables table with descriptions
- Outputs table
- Best practices section
- Troubleshooting guidance
- Related modules and references

### Test Documentation
- Clear test function names
- Comments explaining test purpose
- Documentation of prerequisites
- Expected outcomes

### Code Comments
- Explain WHY, not WHAT
- Document complex logic
- Include TODO/FIXME for known issues
- Reference related issues or PRs

## Resources and References

### Terraform
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [GCS Terraform Resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)

### Testing
- [Terratest Documentation](https://terratest.gruntwork.io/docs/)
- [Terratest GCP Module](https://pkg.go.dev/github.com/gruntwork-io/terratest/modules/gcp)
- [Go Testing Package](https://pkg.go.dev/testing)

### GCP
- [GCS Documentation](https://cloud.google.com/storage/docs)
- [GCS Lifecycle Management](https://cloud.google.com/storage/docs/lifecycle)
- [GCS IAM Roles](https://cloud.google.com/storage/docs/access-control/iam-roles)
- [GCS Pub/Sub Notifications](https://cloud.google.com/storage/docs/pubsub-notifications)

### Project Documentation
- [Main README](README.md)
- [Testing Guide](docs/testing.md)
- [Troubleshooting Guide](docs/troubleshooting.md)
- [Module Documentation](modules/)
- [Examples](examples/)

## Support and Collaboration

### Getting Help
- **GitHub Issues**: For bugs and feature requests
- **Slack**: #platform-engineering for questions and discussions
- **Confluence**: Project documentation and research

### Contributing
- Follow the project's code standards
- Write comprehensive tests for new features
- Update documentation with changes
- Use conventional commit messages
- Request reviews from appropriate team members

---

**Remember**: This is a POC demonstrating agentic test creation. Focus on generating high-quality, comprehensive tests that validate infrastructure correctness while maintaining readability and maintainability.
