# 🚀 Quick Start Guide

This guide gets you up and running with the IaC-to-Visual converter in under 5 minutes.

## Prerequisites Check

```bash
# Check versions
terraform --version  # >= 1.5.0
python3 --version    # >= 3.11
go version          # >= 1.21 (optional, for tests)
```

## Option 1: Makefile Demo (Easiest)

```bash
# Run complete demo
make demo

# Or individual steps
make plan                  # Terraform plan
make generate-diagrams    # Create visualizations
make generate-tests       # Create test suite
make test-coverage        # Run tests

# Clean up
make clean
```

## Option 2: Manual Steps

### Step 1: Generate Infrastructure Plan

```bash
cd stacks/online-banking

terraform init
terraform plan \
  -var="project_id=demo-project" \
  -var="environment=dev" \
  -out=tfplan
```

### Step 2: Convert to State JSON

```bash
terraform show -json tfplan > terraform.tfstate
```

### Step 3: Generate Diagrams

```bash
# All diagram types
python3 ../../scripts/generate-diagram.py \
  terraform.tfstate \
  -o diagrams/architecture.mmd \
  -t all

# Single type
python3 ../../scripts/generate-diagram.py \
  terraform.tfstate \
  -o diagrams/arch.mmd \
  -t architecture
```

### Step 4: View Diagrams

**Option A: Mermaid Live Editor**
```bash
# Copy content
cat diagrams/architecture-architecture.mmd

# Paste at: https://mermaid.live
```

**Option B: VSCode**
```bash
# Install extension: Markdown Preview Mermaid Support
code diagrams/architecture-architecture.mmd
```

**Option C: Command Line**
```bash
# Just view the content
cat diagrams/architecture-architecture.mmd
```

### Step 5: Generate Tests (Optional)

```bash
cd ../..  # Back to project root

python3 scripts/generate-tests.py \
  stacks/online-banking \
  -o tests/online_banking_generated_test.go

cat tests/online_banking_generated_test.go
```

### Step 6: Run Tests (Optional)

```bash
cd tests

# Install dependencies (first time)
go mod download

# Run tests
go test -v ./...

# With coverage
go test -v -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
open coverage.html
```

## Option 3: GitHub Actions (Full Pipeline)

### Trigger Workflow

**Via Push:**
```bash
git add .
git commit -m "feat: test IaC-to-Visual pipeline"
git push origin main
```

**Via GitHub UI:**
1. Go to **Actions** tab
2. Select **IaC to Visual Pipeline**
3. Click **Run workflow**
4. Select stack: `online-banking`
5. Click **Run workflow**

### View Results

1. Click on workflow run
2. View job logs for each stage
3. Download artifacts:
   - `diagrams-online-banking`
   - `coverage-online-banking`
   - `tests-online-banking`
   - `pipeline-results-<run-number>`

## 🎯 What You Get

After running the demo:

### Generated Diagrams (3 types)
- `architecture-architecture.mmd`: Complete infrastructure
- `architecture-network.mmd`: Network topology
- `architecture-dataflow.mmd`: Data flow

### Generated Tests
- `online_banking_generated_test.go`: Complete test suite
  - Integration tests
  - Resource-specific tests
  - Output validation

### Reports
- `coverage.html`: Test coverage visualization
- `coverage.out`: Coverage data

## 📖 What's Next?

### Explore the Stack

```bash
# View stack structure
cd stacks/online-banking
tree -L 2

# View module documentation
cat modules/frontend/main.tf
cat modules/backend/main.tf
cat modules/database/main.tf
```

### Read Documentation

- **[Demo Guide](docs/DEMO.md)**: Complete walkthrough
- **[Architecture](docs/ARCHITECTURE.md)**: System design
- **[Phase 1 Summary](docs/PHASE1-SUMMARY.md)**: Implementation details

### Customize

**Generate diagrams for different stacks:**
```bash
python3 scripts/generate-diagram.py \
  path/to/your/terraform.tfstate \
  -o output.mmd \
  -t all
```

**Generate tests for your stack:**
```bash
python3 scripts/generate-tests.py \
  path/to/your/stack \
  -o tests/your_stack_test.go
```

## 🐛 Troubleshooting

### Issue: "terraform: command not found"
```bash
# Install Terraform
brew install terraform  # macOS
# or download from: https://www.terraform.io/downloads
```

### Issue: "python3: command not found"
```bash
# Install Python 3.11+
brew install python@3.11  # macOS
# or download from: https://www.python.org/downloads/
```

### Issue: Diagram doesn't render
- Check Mermaid syntax: https://mermaid.live
- Ensure diagram file is valid UTF-8
- Try regenerating: `make generate-diagrams`

### Issue: Tests fail with "Project not found"
```bash
# Tests expect real GCP project
# For demo, tests may fail without credentials
# Focus on test generation and diagram creation
```

## 🎓 Learning Path

1. **Start**: Run `make demo`
2. **Understand**: Read generated diagrams and tests
3. **Explore**: Read [Demo Guide](docs/DEMO.md)
4. **Deep Dive**: Read [Architecture](docs/ARCHITECTURE.md)
5. **Customize**: Modify stack and regenerate

## 💡 Tips

- Use `make help` to see all available commands
- Run `make clean` before regenerating everything
- View diagrams in VS Code for best experience
- GitHub automatically renders Mermaid in .md files
- Copy diagrams to Confluence/Notion/etc easily

## 📞 Support

- **GitHub Issues**: https://github.com/intuitivetp/terraform-gcs-poc/issues
- **Documentation**: `docs/` folder
- **Slack**: #platform-engineering

---

**Estimated Time**: 5-10 minutes
**Difficulty**: Beginner
**Prerequisites**: Terraform, Python 3.11+

**Ready to dive deeper?** → [docs/DEMO.md](docs/DEMO.md)

