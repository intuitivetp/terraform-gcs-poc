#!/bin/bash
# Generate architecture diagrams from Terraform state

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default values
STATE_FILE="${1:-terraform.tfstate}"
OUTPUT_DIR="${2:-diagrams}"
DIAGRAM_TYPE="${3:-all}"

echo "🎨 Terraform to Mermaid Diagram Generator"
echo "=========================================="
echo ""

# Check if state file exists
if [ ! -f "$STATE_FILE" ]; then
    echo "❌ Error: State file not found: $STATE_FILE"
    echo ""
    echo "Usage: $0 [state_file] [output_dir] [type]"
    echo "  state_file: Path to terraform.tfstate (default: terraform.tfstate)"
    echo "  output_dir: Output directory (default: diagrams)"
    echo "  type: architecture|network|dataflow|all (default: all)"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "📁 State file: $STATE_FILE"
echo "📂 Output directory: $OUTPUT_DIR"
echo "🎯 Diagram type: $DIAGRAM_TYPE"
echo ""

# Generate diagrams
python3 "$SCRIPT_DIR/generate-diagram.py" \
    "$STATE_FILE" \
    -o "$OUTPUT_DIR/architecture.mmd" \
    -t "$DIAGRAM_TYPE"

echo ""
echo "✅ Diagrams generated successfully!"
echo ""
echo "📊 View diagrams:"
echo "  - Mermaid Live Editor: https://mermaid.live"
echo "  - VSCode Mermaid Preview: Install 'Markdown Preview Mermaid Support' extension"
echo "  - GitHub: Embed in README.md"
echo ""

