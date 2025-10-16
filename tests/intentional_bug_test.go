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
			"project_id":  "devops-sandbox-452616",  // Fixed: Correct project ID
			"bucket_name": "test-bucket-bug",
		},
		//ExpectErrors: []string{"*Error applying plan*"}, // Removed: ExpectErrors is not a valid field
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	// Fixed: Expect no error
	assert.NoError(t, err)
}
```
