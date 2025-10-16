package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestBuggyBucketConfiguration(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/gcs-bucket",
		Vars: map[string]interface{}{
			"project_id":  "wrong-project-id-12345",  // BUG 1: Wrong project ID
			"bucket_name": "test-bucket-bug",
		},
	}

	// BUG 2: Missing defer terraform.Destroy() - resource leak!
	terraform.InitAndApply(t, terraformOptions)

	// BUG 3: Wrong assertion - will fail
	bucketName := terraform.Output(t, terraformOptions, "bucket_name")
	assert.Equal(t, "expected-wrong-name", bucketName)  // Wrong expectation
}
