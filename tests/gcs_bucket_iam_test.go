package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestGCSBucketIAM(t *testing.T) {
	t.Parallel()

	projectID := "devops-sandbox-452616"
	location := "US"
	uniqueID := strings.ToLower(random.UniqueId())
	bucketName := fmt.Sprintf("terratest-iam-%s", uniqueID)
	member := "user:test@example.com"
	role := "roles/storage.objectViewer"

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/gcs-bucket-iam",
		Vars: map[string]interface{}{
			"project_id":  projectID,
			"bucket_name": bucketName,
			"member":      member,
			"role":        role,
			"location":    location,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Verify the bucket exists
	_, err := gcp.FetchGCSBucket(t, projectID, bucketName)
	assert.NoError(t, err)

	// Basic check to see if the IAM binding was created (more robust checks would require GCP APIs)
	iamBindingID := terraform.Output(t, terraformOptions, "iam_binding_id")
	assert.NotEmpty(t, iamBindingID)
}
```