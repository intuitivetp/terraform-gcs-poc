# GCS Bucket Notification Module

This module creates Pub/Sub notifications for Google Cloud Storage bucket events, enabling event-driven workflows when objects are created, updated, or deleted.

## Features

- **Event-Driven Architecture**: React to bucket events in real-time
- **Flexible Event Types**: Configure which events trigger notifications
- **Payload Formats**: Support for JSON and text payload formats
- **Object Filtering**: Optional prefix and suffix filters

## Usage

### Basic Example

```hcl
module "bucket_notification" {
  source = "./modules/gcs-bucket-notification"

  bucket = "my-bucket-name"
  topic  = "projects/my-project/topics/bucket-events"
}
```

### Complete Example with Bucket and Topic

```hcl
# Create a Pub/Sub topic
resource "google_pubsub_topic" "bucket_events" {
  name    = "bucket-events"
  project = "my-project"
}

# Create a bucket
module "data_bucket" {
  source = "./modules/gcs-bucket"

  project_id  = "my-project"
  bucket_name = "data-processing-bucket"
  location    = "US"
}

# Configure notifications
module "bucket_notification" {
  source = "./modules/gcs-bucket-notification"

  bucket         = module.data_bucket.name
  topic          = google_pubsub_topic.bucket_events.id
  event_types    = ["OBJECT_FINALIZE", "OBJECT_DELETE"]
  payload_format = "JSON_API_V1"
}

# Create subscription to process events
resource "google_pubsub_subscription" "bucket_events_sub" {
  name  = "bucket-events-subscription"
  topic = google_pubsub_topic.bucket_events.id

  ack_deadline_seconds = 20
  message_retention_duration = "604800s"  # 7 days
}
```

### Filtered Notifications

```hcl
module "csv_upload_notification" {
  source = "./modules/gcs-bucket-notification"

  bucket              = module.data_bucket.name
  topic               = google_pubsub_topic.csv_uploads.id
  event_types         = ["OBJECT_FINALIZE"]
  payload_format      = "JSON_API_V1"
  object_name_prefix  = "uploads/"
  custom_attributes = {
    file_type = "csv"
    priority  = "high"
  }
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `bucket` | Name of the GCS bucket | `string` | - | yes |
| `topic` | Pub/Sub topic ID (format: `projects/PROJECT/topics/TOPIC`) | `string` | - | yes |
| `event_types` | List of event types to notify on | `list(string)` | `["OBJECT_FINALIZE"]` | no |
| `payload_format` | Format of notification payload | `string` | `"JSON_API_V1"` | no |
| `object_name_prefix` | Filter by object name prefix | `string` | `null` | no |
| `custom_attributes` | Custom attributes to include in notifications | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `notification_id` | The ID of the notification configuration |
| `self_link` | The URI of the created notification |

## Event Types

| Event Type | Description | Use Case |
|------------|-------------|----------|
| `OBJECT_FINALIZE` | Object upload completed | Trigger processing pipelines |
| `OBJECT_DELETE` | Object deleted | Track deletions, cleanup |
| `OBJECT_METADATA_UPDATE` | Object metadata changed | Audit metadata changes |
| `OBJECT_ARCHIVE` | Object archived (versioning) | Track versioned objects |

### Multiple Event Types

```hcl
event_types = [
  "OBJECT_FINALIZE",
  "OBJECT_DELETE",
  "OBJECT_METADATA_UPDATE"
]
```

## Payload Formats

### JSON_API_V1 (Recommended)
Returns detailed JSON with object metadata:
```json
{
  "kind": "storage#object",
  "id": "bucket/object/123456789",
  "name": "uploads/data.csv",
  "bucket": "my-bucket",
  "generation": "123456789",
  "size": "1024",
  "contentType": "text/csv",
  "timeCreated": "2025-01-15T10:30:00.000Z",
  "updated": "2025-01-15T10:30:00.000Z"
}
```

### NONE
Minimal notification without object attributes. Use when you only need to know an event occurred and will fetch details separately.

## Object Filtering

### Prefix Filter
Only notify for objects with specific prefix:
```hcl
object_name_prefix = "uploads/csv/"
```

This filters for objects like:
- ✅ `uploads/csv/data.csv`
- ✅ `uploads/csv/reports/summary.csv`
- ❌ `uploads/json/data.json`

### Use Cases for Filtering

**Organized by folder:**
```hcl
# Notify only for CSV files
object_name_prefix = "data/csv/"

# Notify only for images
object_name_prefix = "images/"
```

**Organized by date:**
```hcl
# Notify only for today's uploads
object_name_prefix = "uploads/${formatdate("YYYY-MM-DD", timestamp())}/"
```

## Custom Attributes

Add metadata to notifications for routing or filtering:

```hcl
custom_attributes = {
  environment = "production"
  source      = "etl-pipeline"
  priority    = "high"
  team        = "data-engineering"
}
```

These attributes are included in the Pub/Sub message and can be used for:
- Message filtering in subscriptions
- Routing to different handlers
- Adding context for processing

## IAM Permissions

### Required Permissions

The Pub/Sub topic must grant the GCS service account permission to publish:

```hcl
resource "google_pubsub_topic_iam_member" "gcs_publisher" {
  topic  = google_pubsub_topic.bucket_events.id
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

data "google_project" "project" {
  project_id = "my-project"
}
```

## Examples

### Image Upload Pipeline

```hcl
# Notify when images are uploaded
module "image_upload_notification" {
  source = "./modules/gcs-bucket-notification"

  bucket             = module.image_bucket.name
  topic              = google_pubsub_topic.image_uploads.id
  event_types        = ["OBJECT_FINALIZE"]
  payload_format     = "JSON_API_V1"
  object_name_prefix = "uploads/images/"
  
  custom_attributes = {
    processing_type = "image-resize"
    environment     = "production"
  }
}
```

### Data Deletion Audit

```hcl
# Track all deletions for audit
module "deletion_audit" {
  source = "./modules/gcs-bucket-notification"

  bucket         = module.data_bucket.name
  topic          = google_pubsub_topic.audit_log.id
  event_types    = ["OBJECT_DELETE"]
  payload_format = "JSON_API_V1"
  
  custom_attributes = {
    audit_type = "deletion"
    severity   = "high"
  }
}
```

### Multi-Event Monitoring

```hcl
# Monitor all changes to critical data
module "critical_data_monitor" {
  source = "./modules/gcs-bucket-notification"

  bucket      = module.compliance_bucket.name
  topic       = google_pubsub_topic.critical_events.id
  event_types = [
    "OBJECT_FINALIZE",
    "OBJECT_DELETE",
    "OBJECT_METADATA_UPDATE",
    "OBJECT_ARCHIVE"
  ]
  payload_format = "JSON_API_V1"
  
  custom_attributes = {
    compliance = "required"
    alert      = "true"
  }
}
```

### Environment-Specific Notifications

```hcl
# Production notifications
module "prod_notification" {
  source = "./modules/gcs-bucket-notification"

  bucket         = module.prod_bucket.name
  topic          = google_pubsub_topic.prod_events.id
  event_types    = ["OBJECT_FINALIZE"]
  payload_format = "JSON_API_V1"
  
  custom_attributes = {
    environment = "production"
    alert_ops   = "true"
  }
}

# Development notifications (different topic)
module "dev_notification" {
  source = "./modules/gcs-bucket-notification"

  bucket         = module.dev_bucket.name
  topic          = google_pubsub_topic.dev_events.id
  event_types    = ["OBJECT_FINALIZE", "OBJECT_DELETE"]
  payload_format = "JSON_API_V1"
  
  custom_attributes = {
    environment = "development"
    alert_ops   = "false"
  }
}
```

## Processing Notifications

### Cloud Function Example (Python)

```python
import json
import base64
from google.cloud import storage

def process_notification(event, context):
    """Process GCS notification from Pub/Sub."""
    
    # Decode message
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    message_data = json.loads(pubsub_message)
    
    # Extract object details
    bucket_name = message_data['bucket']
    object_name = message_data['name']
    
    print(f"Processing {object_name} from {bucket_name}")
    
    # Your processing logic here
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(object_name)
    
    # Process the object...
    
    return 'OK'
```

### Cloud Run Service Example (Node.js)

```javascript
const express = require('express');
const app = express();

app.post('/notification', express.json(), (req, res) => {
  const message = req.body.message;
  const data = Buffer.from(message.data, 'base64').toString();
  const notification = JSON.parse(data);
  
  console.log('Bucket:', notification.bucket);
  console.log('Object:', notification.name);
  console.log('Event:', notification.eventType);
  
  // Process notification...
  
  res.status(200).send('OK');
});

app.listen(8080);
```

## Best Practices

### 1. Use Specific Event Types
Only subscribe to events you need:
```hcl
# ✅ Good: Only finalize events
event_types = ["OBJECT_FINALIZE"]

# ❌ Avoid: All events when not needed
event_types = ["OBJECT_FINALIZE", "OBJECT_DELETE", "OBJECT_METADATA_UPDATE", "OBJECT_ARCHIVE"]
```

### 2. Apply Prefix Filters
Reduce unnecessary notifications:
```hcl
object_name_prefix = "data/csv/"  # Only CSV folder
```

### 3. Use JSON Payload
Prefer `JSON_API_V1` for rich metadata:
```hcl
payload_format = "JSON_API_V1"
```

### 4. Add Custom Attributes
Include context for processing:
```hcl
custom_attributes = {
  environment = var.environment
  source      = "terraform"
}
```

### 5. Handle Idempotency
Process notifications idempotently (same event may be delivered multiple times)

## Troubleshooting

### Notifications Not Received
1. **Check IAM permissions**: Ensure GCS service account can publish to topic
2. **Verify topic exists**: Confirm topic ID is correct
3. **Check subscription**: Create a subscription to receive messages
4. **Wait for delivery**: Initial notifications may take a few minutes

### Permission Denied
**Error**: `Error creating notification: googleapi: Error 403`

**Solution**: Grant GCS service account publish permission:
```bash
PROJECT_NUMBER=$(gcloud projects describe PROJECT_ID --format="value(projectNumber)")

gcloud pubsub topics add-iam-policy-binding TOPIC_NAME \
  --member="serviceAccount:service-${PROJECT_NUMBER}@gs-project-accounts.iam.gserviceaccount.com" \
  --role="roles/pubsub.publisher"
```

### Duplicate Notifications
**Issue**: Receiving multiple notifications for same event

**Solution**: This is expected behavior. Implement idempotent processing using object generation numbers.

## Related Modules

- **[gcs-bucket](../gcs-bucket/)**: Create and configure GCS buckets
- **[gcs-bucket-iam](../gcs-bucket-iam/)**: Manage bucket IAM permissions

## References

- [GCS Pub/Sub Notifications](https://cloud.google.com/storage/docs/pubsub-notifications)
- [Pub/Sub Overview](https://cloud.google.com/pubsub/docs/overview)
- [Event Types](https://cloud.google.com/storage/docs/pubsub-notifications#events)
- [Terraform Notification Resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_notification)

## Support

For issues or questions:
- Open an issue in the [repository](https://github.com/intuitivetp/terraform-gcs-poc/issues)
- Contact the Platform Engineering team on Slack: #platform-engineering

