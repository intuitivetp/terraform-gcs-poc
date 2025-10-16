```go
package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestGCSBucketIAM(t *testing.T) {
	t.Parallel()

	projectID := "devops-sandbox-452616"
	bucketName := fmt.Sprintf("terratest-iam-%s", strings.ToLower(gcp.RandomId()))
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

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Verify the bucket exists
	_, err := gcp.FetchGcsBucket(t, projectID, bucketName)
	assert.NoError(t, err)

	// Basic check to see if the IAM binding was created.  More detailed checks can be added.
	iamBindingID := terraform.Output(t, terraformOptions, "iam_binding_id")
	assert.NotEmpty(t, iamBindingID)
}
```