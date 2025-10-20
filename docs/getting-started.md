# Getting Started

Use this guide to stand up the IaC-to-Visual demo locally in a few minutes. Every command assumes you are at the repository root.

## Prerequisites
- Terraform ≥ 1.5.0 (`terraform -version`)
- Python ≥ 3.11 (`python3 --version`)
- Go ≥ 1.21 (required for tests; `go version`)
- Make (optional but recommended for the scripted demo)
- Access to a GCP project if you want to run real applies; the default flow uses mock plans

## Clone And Prepare
```bash
git clone https://github.com/intuitivetp/terraform-gcs-poc.git
cd terraform-gcs-poc
chmod +x scripts/*.py scripts/*.sh
```

## One-Command Demo
- `make demo` runs init, generates a Terraform plan, creates diagrams, generates tests, and builds coverage artifacts using the online-banking stack.
- `make clean` removes generated plans, diagrams, and Go build artifacts so you can rerun the flow.

## Manual Walkthrough
```bash
# 1. Create a Terraform plan (mock project settings are fine for diagrams/tests)
cd stacks/online-banking
terraform init -backend=false
terraform plan \
  -var="project_id=demo-project" \
  -var="environment=dev" \
  -out=tfplan
terraform show -json tfplan > terraform.tfstate

# 2. Generate diagrams from the plan JSON
python3 ../../scripts/generate-diagram.py terraform.tfstate \
  -o diagrams/architecture.mmd \
  -t all

# 3. Generate Terratest suites
cd ../..
python3 scripts/generate-tests.py stacks/online-banking \
  -o tests/online_banking_generated_test.go

# 4. Run tests with coverage
cd tests
go mod download
go test -v -coverprofile=coverage.out -covermode=atomic ./...
go tool cover -html=coverage.out -o coverage.html
```

## Trigger The GitHub Workflow
- Push to `main` or `develop` with Terraform, module, or script changes to run the full `IaC to Visual Pipeline (AI-Enhanced)` workflow automatically.
- Or run it manually: **Actions → IaC to Visual Pipeline (AI-Enhanced) → Run workflow**, optionally selecting a stack name (`online-banking` or `wealth-management`), toggling self-healing, and setting `run_real_apply=true` when you want Terraform to apply/destroy resources in GCP.
- Download artifacts for diagrams, generated tests, coverage reports, and the curated `demo-bundle` directly from the workflow run summary.

## Next Steps
- `docs/demo-playbook.md` gives the customer-facing agenda.
- `docs/testing.md` covers Terratest patterns and extra commands.
- `docs/troubleshooting.md` lists common failures and quick fixes when Terraform or Go tooling complains.
