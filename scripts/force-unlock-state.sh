#!/bin/bash
# Force Unlock Terraform State
# 
# This script helps manually release Terraform state locks that may be stuck
# from failed workflow runs.
#
# Usage:
#   ./scripts/force-unlock-state.sh <stack-name> <lock-id>
#
# Example:
#   ./scripts/force-unlock-state.sh online-banking 1760655035807724

set -e

STACK_NAME="${1}"
LOCK_ID="${2}"

if [ -z "$STACK_NAME" ] || [ -z "$LOCK_ID" ]; then
    echo "❌ Error: Missing required arguments"
    echo ""
    echo "Usage: $0 <stack-name> <lock-id>"
    echo ""
    echo "Example:"
    echo "  $0 online-banking 1760655035807724"
    echo ""
    echo "You can find the lock ID in the GitHub Actions error message:"
    echo "  Lock Info:"
    echo "    ID:        1760655035807724  <-- This is the lock ID"
    exit 1
fi

STACK_DIR="stacks/${STACK_NAME}"

if [ ! -d "$STACK_DIR" ]; then
    echo "❌ Error: Stack directory not found: $STACK_DIR"
    exit 1
fi

echo "🔓 Force Unlocking Terraform State"
echo "=================================="
echo "Stack: $STACK_NAME"
echo "Lock ID: $LOCK_ID"
echo ""

cd "$STACK_DIR"

# Check if backend configuration exists
if [ ! -f "backend.tf" ]; then
    echo "⚠️  No backend.tf found, creating temporary one..."
    
    # Ask for bucket name
    read -p "Enter GCS bucket name (or press Enter for default): " BUCKET
    BUCKET=${BUCKET:-terraform-state-iac-to-visual}
    
    cat > backend.tf << EOF
terraform {
  backend "gcs" {
    bucket = "$BUCKET"
    prefix = "stacks/$STACK_NAME"
  }
}
EOF
    echo "✅ Created temporary backend.tf"
fi

# Initialize
echo ""
echo "📝 Initializing Terraform..."
terraform init

# Force unlock
echo ""
echo "🔓 Force unlocking state..."
if terraform force-unlock -force "$LOCK_ID"; then
    echo "✅ State lock successfully released!"
else
    echo "❌ Failed to release lock"
    echo ""
    echo "💡 Alternative methods:"
    echo ""
    echo "1. Via gcloud CLI (if you have access):"
    echo "   gsutil rm gs://$BUCKET/stacks/$STACK_NAME/default.tflock"
    echo ""
    echo "2. Via GitHub Actions:"
    echo "   - Go to Actions → Run workflow manually"
    echo "   - The cleanup job will attempt to release locks"
    echo ""
    echo "3. Wait for lock to expire (usually 15-30 minutes)"
    exit 1
fi

# Optional: Run destroy to clean up resources
echo ""
read -p "🧹 Do you want to destroy all resources in this stack? (y/N): " DESTROY
if [ "$DESTROY" = "y" ] || [ "$DESTROY" = "Y" ]; then
    echo ""
    echo "💥 Destroying resources..."
    
    # Get project ID
    read -p "Enter GCP project ID: " PROJECT_ID
    
    terraform destroy \
        -var="project_id=$PROJECT_ID" \
        -var="environment=dev" \
        -auto-approve
    
    echo "✅ Resources destroyed"
else
    echo "⏭️  Skipping destroy"
fi

echo ""
echo "✅ Done!"

