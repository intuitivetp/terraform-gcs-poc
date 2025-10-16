# Testing Guide

This guide covers testing practices, patterns, and best practices for the terraform-gcs-poc project using Terratest.

## Overview

This project uses [Terratest](https://terratest.gruntwork.io/), a Go testing framework for infrastructure code. Tests validate that Terraform modules correctly provision GCP resources with expected configurations.

## Test Structure

```
tests/
├── gcs_bucket_test.go              # Core bucket module tests
├── gcs_bucket_iam_test.go          # IAM binding tests
├── gcs_bucket_notification_test.go # Pub/Sub notification tests
├── intentional_bug_test.go         # Example failure test
├── go.mod                          # Go dependencies
└── go.sum                          # Dependency checksums
```

## Prerequisites

### Required Tools
- **Go** >= 1.21
- **Terraform** >= 1.0
- **gcloud CLI** configured with credentials
- **GCP Project** with billing enabled

### GCP Permissions
Your account or service account needs:
- `roles/storage.admin` - Manage buckets and objects
- `roles/iam.serviceAccountUser` - Use service accounts
- `roles/pubsub.admin` - Manage Pub/Sub topics (for notification tests)

### Environment Setup

```bash
# Set GCP project
export GOOGLE_PROJECT=your-project-id

# Authenticate
gcloud auth application-default login

# Verify access
gcloud projects describe $GOOGLE_PROJECT
```

## Running Tests

### All Tests
```bash
cd tests
go mod download
go test -v -timeout 30m
```

### Specific Test
```bash
go test -v -run TestGCSBucketCreation -timeout 30m
```

### Parallel Execution
```bash
go test -v -parallel 3 -timeout 30m
```

### With Coverage
```bash
go test -v -cover -timeout 30m
```

### Short Tests (Skip Long-Running Tests)
```bash
go test -v -short -timeout 10m
```

## Test Patterns

### Basic Test Structure

```go
func TestGCSBucketCreation(t *testing.T) {
    t.Parallel() // Run in parallel with other tests
    
    // Generate unique names
    uniqueID := random.UniqueId()
    bucketName := fmt.Sprintf("test-bucket-%s", strings.ToLower(uniqueID))
    
    // Configure Terraform options
    terraformOptions := &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "project_id":  gcp.GetGoogleProjectIDFromEnvVar(t),
            "bucket_name": bucketName,
        },
    }
    
    // Cleanup after test
    defer terraform.Destroy(t, terraformOptions)
    
    // Apply Terraform
    terraform.InitAndApply(t, terraformOptions)
    
    // Validate outputs
    outputBucketName := terraform.Output(t, terraformOptions, "bucket_name")
    assert.Equal(t, bucketName, outputBucketName)
    
    // Validate actual GCP resource
    bucket := gcp.GetGCSBucketMetadata(t, bucketName)
    assert.Equal(t, "US", bucket.Location)
}
```

### Key Components

#### 1. Parallel Execution
```go
t.Parallel()
```
Allows tests to run concurrently, reducing total test time.

#### 2. Unique Resource Names
```go
uniqueID := random.UniqueId()
bucketName := fmt.Sprintf("test-bucket-%s", strings.ToLower(uniqueID))
```
Prevents naming conflicts when tests run in parallel or sequentially.

#### 3. Defer Cleanup
```go
defer terraform.Destroy(t, terraformOptions)
```
Ensures resources are destroyed even if test fails.

#### 4. Terraform Operations
```go
terraform.InitAndApply(t, terraformOptions)  // Init + Plan + Apply
terraform.Apply(t, terraformOptions)         // Just Apply
terraform.Destroy(t, terraformOptions)       // Destroy
```

#### 5. Output Validation
```go
outputValue := terraform.Output(t, terraformOptions, "output_name")
assert.Equal(t, expectedValue, outputValue)
```

#### 6. GCP Resource Validation
```go
bucket := gcp.GetGCSBucketMetadata(t, bucketName)
assert.Equal(t, "US", bucket.Location)
assert.True(t, bucket.Versioning.Enabled)
```

## Test Examples

### Testing Bucket Creation

```go
func TestGCSBucketWithVersioning(t *testing.T) {
    t.Parallel()
    
    uniqueID := random.UniqueId()
    bucketName := fmt.Sprintf("versioned-bucket-%s", strings.ToLower(uniqueID))
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "project_id":         gcp.GetGoogleProjectIDFromEnvVar(t),
            "bucket_name":        bucketName,
            "versioning_enabled": true,
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Verify versioning is enabled
    bucket := gcp.GetGCSBucketMetadata(t, bucketName)
    assert.True(t, bucket.Versioning.Enabled)
}
```

### Testing IAM Bindings

```go
func TestGCSBucketIAMBinding(t *testing.T) {
    t.Parallel()
    
    projectID := gcp.GetGoogleProjectIDFromEnvVar(t)
    uniqueID := random.UniqueId()
    bucketName := fmt.Sprintf("iam-test-%s", strings.ToLower(uniqueID))
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/gcs-bucket-iam",
        Vars: map[string]interface{}{
            "bucket": bucketName,
            "role":   "roles/storage.objectViewer",
            "members": []string{
                fmt.Sprintf("serviceAccount:test@%s.iam.gserviceaccount.com", projectID),
            },
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    
    // First create the bucket (prerequisite)
    createBucket(t, projectID, bucketName)
    defer deleteBucket(t, bucketName)
    
    terraform.InitAndApply(t, terraformOptions)
    
    // Verify IAM binding exists
    policy := gcp.GetBucketIamPolicy(t, bucketName)
    assert.Contains(t, policy.Bindings, "roles/storage.objectViewer")
}
```

### Testing Notifications

```go
func TestGCSBucketNotification(t *testing.T) {
    t.Parallel()
    
    projectID := gcp.GetGoogleProjectIDFromEnvVar(t)
    uniqueID := random.UniqueId()
    bucketName := fmt.Sprintf("notif-test-%s", strings.ToLower(uniqueID))
    topicName := fmt.Sprintf("notif-topic-%s", uniqueID)
    
    // Create Pub/Sub topic (prerequisite)
    topicID := createPubSubTopic(t, projectID, topicName)
    defer deletePubSubTopic(t, topicID)
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/gcs-bucket-notification",
        Vars: map[string]interface{}{
            "bucket":      bucketName,
            "topic":       topicID,
            "event_types": []string{"OBJECT_FINALIZE"},
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    
    createBucket(t, projectID, bucketName)
    defer deleteBucket(t, bucketName)
    
    terraform.InitAndApply(t, terraformOptions)
    
    // Verify notification exists
    notifications := gcp.GetBucketNotifications(t, bucketName)
    assert.NotEmpty(t, notifications)
}
```

### Negative Testing

```go
func TestGCSBucketInvalidLocation(t *testing.T) {
    t.Parallel()
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "project_id":  gcp.GetGoogleProjectIDFromEnvVar(t),
            "bucket_name": "test-bucket",
            "location":    "INVALID_LOCATION",
        },
    }
    
    // Expect this to fail
    _, err := terraform.InitAndApplyE(t, terraformOptions)
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "invalid location")
}
```

## Best Practices

### 1. Always Use Unique Names
```go
// ✅ Good: Unique name
uniqueID := random.UniqueId()
bucketName := fmt.Sprintf("test-%s", strings.ToLower(uniqueID))

// ❌ Bad: Static name causes conflicts
bucketName := "test-bucket"
```

### 2. Always Defer Cleanup
```go
// ✅ Good: Resources cleaned up even on failure
defer terraform.Destroy(t, terraformOptions)

// ❌ Bad: Resources leak on test failure
terraform.InitAndApply(t, terraformOptions)
// ... test logic ...
terraform.Destroy(t, terraformOptions)  // Never reached if test fails
```

### 3. Use Parallel Tests
```go
// ✅ Good: Faster test execution
func TestBucket(t *testing.T) {
    t.Parallel()
    // ...
}

// ⚠️ Avoid: Sequential execution is slower
func TestBucket(t *testing.T) {
    // No t.Parallel()
    // ...
}
```

### 4. Test Real Resources
```go
// ✅ Good: Verify actual GCP state
bucket := gcp.GetGCSBucketMetadata(t, bucketName)
assert.Equal(t, "US", bucket.Location)

// ❌ Insufficient: Only checking Terraform output
outputLocation := terraform.Output(t, terraformOptions, "location")
assert.Equal(t, "US", outputLocation)
```

### 5. Set Appropriate Timeouts
```bash
# ✅ Good: Sufficient time for GCP operations
go test -v -timeout 30m

# ❌ Bad: Default 10m may be too short
go test -v
```

### 6. Use Descriptive Test Names
```go
// ✅ Good: Clear what is being tested
func TestGCSBucketCreationWithVersioningEnabled(t *testing.T)

// ❌ Bad: Vague test name
func TestBucket(t *testing.T)
```

## Common Issues and Solutions

### Issue: Bucket Already Exists
**Error**: `googleapi: Error 409: You already own this bucket`

**Solution**: Use unique names with random suffixes
```go
uniqueID := random.UniqueId()
bucketName := fmt.Sprintf("test-%s", strings.ToLower(uniqueID))
```

### Issue: Permission Denied
**Error**: `Error 403: ... does not have storage.buckets.create access`

**Solution**: Grant required permissions
```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:YOUR_EMAIL" \
  --role="roles/storage.admin"
```

### Issue: Test Timeout
**Error**: `panic: test timed out after 10m0s`

**Solution**: Increase timeout
```bash
go test -v -timeout 30m
```

### Issue: Resources Not Cleaned Up
**Problem**: Failed tests leave resources in GCP

**Solution**: 
1. Use `defer terraform.Destroy()` in all tests
2. Manually clean up if test crashed:
```bash
# List buckets
gsutil ls

# Delete bucket
gsutil rm -r gs://bucket-name
```

### Issue: Parallel Test Conflicts
**Error**: Random failures when running in parallel

**Solution**: Ensure truly unique resource names and avoid shared state

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Terraform Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: '1.6'
      
      - name: Authenticate to GCP
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
      
      - name: Run Tests
        working-directory: tests
        run: |
          go mod download
          go test -v -timeout 30m
        env:
          GOOGLE_PROJECT: ${{ secrets.GCP_PROJECT_ID }}
```

## Test Coverage Goals

- **Minimum**: 80% module coverage
- **Each module**: At least one integration test
- **Each variable**: Tested with default and custom values
- **Include**: Negative test cases where applicable

## Writing New Tests

### Checklist
- [ ] Test name clearly describes what is being tested
- [ ] Uses `t.Parallel()` for parallel execution
- [ ] Generates unique resource names
- [ ] Uses `defer terraform.Destroy()` for cleanup
- [ ] Validates Terraform outputs
- [ ] Validates actual GCP resource state
- [ ] Includes assertions with meaningful messages
- [ ] Has appropriate timeout (30m for integration tests)
- [ ] Documents any prerequisites or setup requirements

### Test Template

```go
func TestModuleName_ScenarioDescription(t *testing.T) {
    t.Parallel()
    
    // Arrange: Setup test data
    projectID := gcp.GetGoogleProjectIDFromEnvVar(t)
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
    
    // Assert: Verify outputs
    output := terraform.Output(t, terraformOptions, "output_name")
    assert.Equal(t, "expected_value", output, "Output mismatch")
    
    // Assert: Verify GCP resource
    resource := gcp.GetResource(t, resourceName)
    assert.NotNil(t, resource, "Resource should exist")
    assert.Equal(t, "expected", resource.Property)
}
```

## Resources

- [Terratest Documentation](https://terratest.gruntwork.io/docs/)
- [Terratest GCP Module](https://pkg.go.dev/github.com/gruntwork-io/terratest/modules/gcp)
- [Go Testing Package](https://pkg.go.dev/testing)
- [Testify Assertions](https://pkg.go.dev/github.com/stretchr/testify/assert)

## Support

For testing questions or issues:
- Review existing tests for examples
- Check [GitHub Issues](https://github.com/intuitivetp/terraform-gcs-poc/issues)
- Reach out on Slack: #platform-engineering

