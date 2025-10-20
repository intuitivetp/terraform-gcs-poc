# Development Guide

Keep contributions consistent, testable, and demo-ready. This guide combines the Terraform/Terratest standards plus the AI agent guardrails that power automation in this repo.

## Project Context
- Goal: demonstrate AI-assisted test creation and validation for Google Cloud Storage patterns delivered as Terraform modules.
- Primary consumers: platform engineers running demos, contributors extending modules, and AI agents assisting with fixes or reviews.
- Canonical resources: reusable modules in `modules/`, full-stack examples in `stacks/`, automation scripts in `scripts/`, and Terratest suites in `tests/`.

## Repository Tour
- `modules/` — base modules (`gcs-bucket`, `gcs-bucket-iam`, `gcs-bucket-notification`) with documentation in each `README.md`.
- `stacks/online-banking/` — end-to-end reference stack used by the demo and CI pipeline.
- `scripts/` — Python helpers for diagram and test generation plus shell wrappers.
- `tests/` — Terratest suites (`*_test.go`) and generated files; keep hand-written tests alongside generated ones.
- `docs/` — the source of truth for onboarding, demos, workflows, and support materials.

## Terraform Standards
- Pin Terraform and provider versions in every module; prefer `>= 1.5.0` for Terraform and `~> 5.0` for `hashicorp/google`.
- Enforce security defaults: `uniform_bucket_level_access = true`, `public_access_prevention = "enforced"`, lifecycle rules where applicable, and opinionated labels.
- Use snake_case for variables and outputs, kebab-case for module directories, and descriptive resource names (`google_storage_bucket.data_bucket`).
- Run `terraform fmt` before committing; CI auto-heals formatting but should rarely find issues.
- Keep modules composable: expose required variables, surface meaningful outputs, and document expectations at the top of each module file.

## Terratest Standards
- Structure tests as `Test<Module><Scenario>` functions, call `t.Parallel()`, and generate unique resource names with `random.UniqueId()` or suffixes.
- Configure `terraform.Options` with explicit `TerraformDir`, `Vars`, and `EnvVars` when needed; avoid re-using state across tests.
- Mock mode is the default: rely on `terraform.Init`, `terraform.Validate`, and `terraform.Plan` without applying real infrastructure for demo runs.
- Always defer cleanup (`defer terraform.Destroy`) when tests eventually reach apply flows; keep the pattern even in mock-mode files for consistency.
- Collect coverage with `go test -coverprofile=coverage.out -covermode=atomic ./...`; the workflow enforces ≥70%.

## AI Agent Guardrails
- Gemini-powered steps only self-fix safe operations (formatting, obvious syntax issues). Anything higher risk must surface a suggestion, not a silent change.
- Provide clear error context in logs (`test-output.log`, plan output) so agents can reason without re-running steps.
- When extending automation, document prompts, expectations, and fallback paths in `docs/AI-SELF-HEALING.md` to keep humans and AI aligned.
- Avoid committing secrets; rely on GitHub Action secrets for credentials and API keys.

## Environment Notes
- Sandbox GCP project: `devops-sandbox-452616`, region `us-central1`; override via workflow inputs or environment variables when pointing at a different project.
- Authenticate locally with `gcloud auth application-default login` and export `GOOGLE_PROJECT` before running real applies.
- Remember that GitHub-hosted runners fetch providers dynamically; vendor provider binaries locally only if you need repeatable offline demos.
- When you need the workflow to perform a real apply/destroy cycle, set the `run_real_apply` dispatch input and ensure `GCP_PROJECT_ID`, `TF_STATE_BUCKET`, and `GCP_CREDENTIALS` secrets are populated.
