package test

import (
	"fmt"
	"testing"
	"time"
	"strings"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestGCSBucketCreation(t *testing.T) {
	t.Parallel()

	// Generate unique bucket name
	projectID := "devops-sandbox-452616"
	bucketName := fmt.Sprintf("test-bucket-%s-%s", projectID, random.UniqueId())

	// Configure Terraform options
	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"project_id": projectID,
			"bucket_name": bucketName,
		},
		RetryableTerraformErrors: map[string]string{
			".*": "Retrying due to eventual consistency",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run terraform init and apply
	terraform.InitAndApply(t, terraformOptions)

	// Get output values
	outputBucketName := terraform.Output(t, terraformOptions, "bucket_name")
	outputBucketURL := terraform.Output(t, terraformOptions, "bucket_url")

	// Verify outputs are not empty
	assert.NotEmpty(t, outputBucketName, "Bucket name should not be empty")
	assert.NotEmpty(t, outputBucketURL, "Bucket URL should not be empty")


}

func TestGCSBucketWithCustomSettings(t *testing.T) {
	t.Parallel()

	projectID := "devops-sandbox-452616"

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/gcs-bucket",
		Vars: map[string]interface{}{
			"project_id":          projectID,
			"bucket_name":         fmt.Sprintf("custom-test-%s", strings.ToLower(random.UniqueId())),
			"location":            "EU",
			"storage_class":       "NEARLINE",
			"versioning_enabled":  false,
			"lifecycle_age_days":  60,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	
}
