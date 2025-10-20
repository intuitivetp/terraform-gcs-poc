# Demo Playbook

Showcase the IaC-to-Visual experience in five minutes. This script balances command-line proof with pipeline storytelling.

## Demo Goals
- Prove Terraform code can become architecture diagrams automatically.
- Highlight AI-assisted testing and self-healing within GitHub Actions.
- Underscore time savings and quality improvements for platform teams.

## Pre-Demo Checklist
- Install Terraform 1.5+, Python 3.11+, Go 1.21+, and Make.
- Run `make clean demo` once before the session to populate diagrams/tests for screenshots.
- Prepare Mermaid Live Editor or VS Code’s Mermaid preview if you want to render diagrams live.
- Log in to GitHub and open the latest successful `IaC to Visual Pipeline (AI-Enhanced)` run in a browser tab.
- Decide whether you want to highlight a **real** Terraform apply—set the workflow dispatch input `run_real_apply=true` and ensure GCP credentials/state bucket secrets are configured before the meeting.

## Live Walkthrough (3 minutes)
```bash
# Explore the stack
cd stacks/online-banking
tree -L 2

# Build a plan and convert it to JSON
terraform init -backend=false
terraform plan -var="project_id=demo" -var="environment=dev" -out=tfplan
terraform show -json tfplan > terraform.tfstate

# Generate every diagram style
python3 ../../scripts/generate-diagram.py terraform.tfstate \
  -o diagrams/architecture.mmd \
  -t all

# Optional: open architecture-architecture.mmd in Mermaid Live Editor

# Generate validation tests
cd ../..
python3 scripts/generate-tests.py stacks/online-banking \
  -o tests/online_banking_generated_test.go
head -40 tests/online_banking_generated_test.go
```

Talking points:
- “We convert Terraform to plan JSON and immediately surface architecture, network, and data-flow diagrams.”
- “Tests are synthesized from the same stack definition and designed to run without needing real GCP credentials.”

## Pipeline Story (2 minutes)
- Show `.github/workflows/iac-to-visual-ai.yml` and call out the stages: detect changes → validate/plan → generate tests → execute tests with coverage → produce diagrams/artifacts → summarize results.
- Highlight the Gemini self-heal steps that analyze failures and auto-fix safe issues like Terraform formatting.
- Scroll to the run summary to point out the exact coverage percentage surfaced from the Go tests.
- In the workflow run UI, grab the ready-made `demo-bundle` artifact—inside you’ll find the latest diagrams, coverage reports, and generated tests packaged for sharing.

## Executive Wrap
- Phase 1 criteria: 95%+ resource capture, three diagram types, automated tests with coverage percentage called out in CI, GitHub-integrated AI assistance.
- Business impact: diagramming drops from hours to seconds, test authoring from half a day to moments, documentation stays in sync after every PR.
- Next steps: expand stack catalog, deepen AI code review, and wire acceptance-criteria validation (see `docs/roadmap.md`).
