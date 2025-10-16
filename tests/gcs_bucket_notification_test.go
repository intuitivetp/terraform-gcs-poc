package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestGCSBucketNotification(t *testing.T) {
	t.Parallel()

	projectID := "devops-sandbox-452616"
	location := "US"
	bucketName := fmt.Sprintf("terratest-notification-%s", strings.ToLower(gcp.RandomId()))
	topicName := fmt.Sprintf("terratest-topic-%s", strings.ToLower(gcp.RandomId()))

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/gcs-bucket-notification",
		Vars: map[string]interface{}{
			"project_id":  projectID,
			"bucket_name": bucketName,
			"topic_name":  topicName,
			"location":    location,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// Verify the bucket exists
	_, err := gcp.FetchGcsBucket(t, projectID, bucketName)
	assert.NoError(t, err)

	// Verify the pubsub topic exists
	_, err = gcp.GetPubSubTopic(t, projectID, topicName)
	assert.NoError(t, err)

	// Verify the notification exists (basic check, more detailed checks can be added)
	notificationID := terraform.Output(t, terraformOptions, "notification_id")
	assert.NotEmpty(t, notificationID)
}