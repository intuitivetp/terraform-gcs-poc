package test

import (
	"fmt"
	"strings"
	"testing"

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

	// Verify the IAM member output matches what we set
	memberOutput := terraform.Output(t, terraformOptions, "member")
	assert.Equal(t, member, memberOutput)
	
	// Verify the role output matches what we set
	roleOutput := terraform.Output(t, terraformOptions, "role")
	assert.Equal(t, role, roleOutput)
}
