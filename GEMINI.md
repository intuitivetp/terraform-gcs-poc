# Gemini CLI Instructions for terraform-gcs-poc

## Project Context
This is a proof-of-concept demonstrating agentic test creation and validation for Terraform code managing Google Cloud Storage buckets.

## Code Standards

### Terraform
- Use Terraform 1.6+ syntax
- Follow Google Cloud naming conventions
- Enable versioning and uniform bucket-level access for all GCS buckets
- Use lifecycle rules for object management
- Tag all resources with appropriate labels

### Terratest
- Write tests in Go using Terratest framework
- Use parallel testing with `t.Parallel()`
- Always include `defer terraform.Destroy()` for cleanup
- Test both successful provisioning and actual GCP resource existence
- Validate resource properties match Terraform configuration
- Use meaningful test function names: `Test<Resource><Scenario>`

### Test Coverage Requirements
- Minimum 80% coverage of Terraform modules
- Each module must have at least one integration test
- Test both default and custom configurations
- Include negative test cases where applicable

## When Generating Tests
1. Analyze existing module structure in `./modules/`
2. Check existing tests in `./tests/` to avoid duplication
3. Generate comprehensive tests covering all resource attributes
4. Use unique identifiers (random suffixes) for resource names
5. Include proper assertions using `testify/assert`
6. Add comments explaining test purpose

## When Fixing Failures
1. Read the full error log carefully
2. Identify if issue is in Terraform code or test code
3. Fix root cause, not symptoms
4. Ensure fix doesn't break other tests
5. Add comments explaining the fix

## Project Structure
.
├── modules/
│ └── gcs-bucket/ # Reusable GCS bucket module
├── tests/ # Terratest Go tests
├── policies/ # OPA policy files
└── .github/workflows/ # CI/CD automation


## GCP Project Details
- Project ID: devops-sandbox-452616
- Project Number: 209427249385
- Region: us-central1
- Environment: Sandbox/Testing

## Important Notes
- All buckets must have globally unique names
- Tests run against real GCP infrastructure
- Always clean up resources in tests
- Follow principle of least privilege for IAM

## Collaboration
- When asked to review PRs, focus on Terraform best practices and test quality
- When asked to generate tests, prioritize comprehensive coverage
- When asked to fix issues, explain your reasoning in commit messages
