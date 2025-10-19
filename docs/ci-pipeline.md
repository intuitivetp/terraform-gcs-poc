# CI Pipeline

The `IaC to Visual Pipeline (AI-Enhanced)` workflow unifies validation, testing, and documentation for every stack. Use this reference when tuning `.github/workflows/iac-to-visual-ai.yml`.

## When It Runs
- Pushes to `main` or `develop` that touch Terraform, modules, or scripts.
- Pull requests against `main` or `develop`.
- Manual dispatch with optional stack override and self-healing toggle.
- Issue or review comments that mention the Gemini reviewer hook.

## Stage Breakdown
1. **Detect Changes** — finds impacted stacks (defaults to `online-banking`) and fans out matrix jobs.
2. **Validate & Plan** — performs format checks, initializes Terraform with a safe backend fallback, and produces a plan for mock execution.
3. **Generate Tests** — runs `scripts/generate-tests.py` per stack and publishes the generated Go files as artifacts.
4. **Run Tests** — installs Go dependencies, executes Terratest suites with coverage, captures logs, and enforces the 70% threshold.
5. **Mock Apply** — replays Terraform in backend-free mode, converts the plan to JSON, and feeds diagram generation without touching GCP.
6. **Publish** — uploads diagrams, coverage, tests, and documentation bundles; creates a concise run summary.
7. **PR Review (conditional)** — uses Gemini (when configured) to annotate pull requests with review feedback.

## Self-Healing Highlights
- Terraform fmt failures auto-trigger `terraform fmt -recursive` and commit-safe fixes.
- Test generation/test execution failures route through Gemini analyzers that surface likely causes and next actions.
- Coverage dips call out remaining work rather than hard-failing the run, keeping demos smooth while still flagging gaps.
- Each AI step logs actionable remediation notes into the workflow summary for follow-up.

## Produced Artifacts
- `diagrams-<stack>` — Mermaid files plus an embedded Markdown overview.
- `tests-<stack>` — generated Go tests ready for check-in if desired.
- `coverage-<stack>` — HTML and text coverage reports, including raw `coverage.out`.
- `pipeline-results-<run>` — aggregated logs and status markdown used for executive updates.

## Maintaining The Workflow
- Align doc updates with `docs/ci-pipeline.md` whenever stages change.
- Keep secrets minimal: `GCP_CREDENTIALS`, `GCP_PROJECT_ID`, and `GEMINI_API_KEY` are optional but unlock full functionality.
- Test major edits with `gh workflow run "IaC to Visual Pipeline (AI-Enhanced)" --ref <branch>` and monitor via `gh run watch`.
- Pair edits with `docs/AI-SELF-HEALING.md` to ensure AI guidance descriptions stay accurate.
