package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestGCSBucketIAM(t *testing.T) {
	t.Parallel()

	projectID := "test-project-12345"
	bucketName := "test-bucket"
	member := "user:test@example.com"
	role := "roles/storage.objectViewer"

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/gcs-bucket-iam",
		Vars: map[string]interface{}{
			"project_id":  projectID,
			"bucket_name": bucketName,
			"member":      member,
			"role":        role,
		},
	}

	// Skip actual apply in mock mode - just validate configuration
	terraform.Init(t, terraformOptions)
	
	// Validate the configuration
	validateOutput := terraform.Validate(t, terraformOptions)
	assert.NotEmpty(t, validateOutput, "Terraform validation should produce output")

	// Generate plan to verify configuration
	planOutput := terraform.Plan(t, terraformOptions)
	assert.Contains(t, planOutput, "google_storage_bucket_iam", "Plan should include GCS bucket IAM resources")
}
