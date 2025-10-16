package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestGCSBucketNotification(t *testing.T) {
	t.Parallel()

	projectID := "test-project-12345"
	location := "US"
	bucketName := "test-notification-bucket"
	topicName := "test-topic"

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/gcs-bucket-notification",
		Vars: map[string]interface{}{
			"project_id":  projectID,
			"bucket_name": bucketName,
			"topic_name":  topicName,
			"location":    location,
		},
	}

	// Skip actual apply in mock mode - just validate configuration
	terraform.Init(t, terraformOptions)
	
	// Validate the configuration
	validateOutput := terraform.Validate(t, terraformOptions)
	assert.NotEmpty(t, validateOutput, "Terraform validation should produce output")

	// Generate plan to verify configuration
	planOutput := terraform.Plan(t, terraformOptions)
	assert.Contains(t, planOutput, "google_storage_bucket_notification", "Plan should include GCS bucket notification resources")
	assert.Contains(t, planOutput, "google_pubsub_topic", "Plan should include Pub/Sub topic resources")
}