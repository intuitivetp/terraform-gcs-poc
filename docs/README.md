# Documentation Hub

This folder collects everything you need to run, explain, and extend the IaC‑to‑Visual demo. Each guide stays focused so you can jump straight to the right reference.

## Orientation
- `docs/getting-started.md` — hands-on quick start for local runs and workflows
- `docs/demo-playbook.md` — 5-minute demo script with talking points and artifacts
- `docs/ci-pipeline.md` — GitHub Actions layout, stage responsibilities, and self-heal flow
- Sample stacks:
  - `stacks/online-banking` for the retail-banking storyline
  - `stacks/wealth-management` for advisory/wealth demos reusing the same automation

## Build & Operate
- `docs/ARCHITECTURE.md` — system design, components, and generated diagram taxonomy
- `docs/AI-SELF-HEALING.md` — Gemini-assisted remediation patterns embedded in the pipeline
- `docs/development-guide.md` — Terraform/Terratest standards, repo tour, and AI agent guardrails

## Validate & Support
- `docs/testing.md` — Terratest usage with examples, coverage guidance, and command snippets
- `docs/troubleshooting.md` — common failure signatures and fastest remediation steps
- `docs/roadmap.md` — near-term backlog, recently delivered milestones, and open questions

## Using The Docs
- Start with `docs/getting-started.md` if you need to run the project locally.
- Jump to `docs/demo-playbook.md` for customer-facing walkthroughs.
- Reference `docs/ci-pipeline.md` whenever you update `.github/workflows/iac-to-visual-ai.yml`.
- Pair `docs/development-guide.md` and `docs/testing.md` to keep contributions aligned with repo standards.
- Show up with artifacts in hand? Grab the `demo-bundle` from any workflow run—`docs/demo-playbook.md` explains how to use it in the presentation flow.
- Planning a real Terraform apply? Follow the guardrails in `docs/ci-pipeline.md` before enabling the `run_real_apply` workflow input.
