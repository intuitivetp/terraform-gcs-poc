# Cleanup Plan

## Items to Remove/Archive

### 1. Deprecated Workflows ⚠️

These workflows are replaced by `iac-to-visual-ai.yml`:

- ❌ `.github/workflows/terraform-ci.yml` - Basic CI (now integrated)
- ❌ `.github/workflows/terraform-to-visual.yml` - Old full pipeline (replaced)

**Action:** Archive or remove

**Decision needed:**
- 🤔 `.github/workflows/gemini-dispatch.yml` - Separate feature for @gemini-cli comments
- 🤔 `.github/workflows/pr-review.yml` - Separate PR review feature

Keep these if they provide value beyond the main pipeline.

### 2. Temporary/Test Files 🧹

- ❌ `fix_tests.py` - Temporary Gemini test-fixing script (root directory)
- ❌ `tests/test_output.log` - Old test output log
- ❌ `tests/intentional_bug_test.go` - Was for testing bug fixes (now resolved)

**Action:** Remove

### 3. Root Terraform Files 🤔

These files exist in root but main stack is in `stacks/online-banking/`:

- `main.tf`
- `outputs.tf`
- `variables.tf`

**Action:** Check if these are old/unused, then remove or document purpose

## Recommended Cleanup Commands

```bash
# 1. Archive deprecated workflows (keep for reference)
mkdir -p .github/workflows/archived
mv .github/workflows/terraform-ci.yml .github/workflows/archived/
mv .github/workflows/terraform-to-visual.yml .github/workflows/archived/

# 2. Remove temporary files
rm fix_tests.py
rm tests/test_output.log
rm tests/intentional_bug_test.go

# 3. Check and remove root Terraform files (if unused)
# First verify they're not referenced anywhere:
git grep -l "root.*main.tf"
# If not used:
rm main.tf outputs.tf variables.tf

# 4. Commit cleanup
git add -A
git commit -m "chore: cleanup deprecated workflows and temporary files

Removed:
- Old terraform-ci.yml and terraform-to-visual.yml (archived)
- Temporary test-fixing scripts
- Unused test output files
- Intentional bug test file (resolved)

Archived workflows are in .github/workflows/archived/ for reference."
```

## Keep/Review Later

### Potentially Useful Workflows

**gemini-dispatch.yml**
- Provides @gemini-cli in comments
- Different use case than self-healing
- **Recommend:** Keep if used, otherwise archive

**pr-review.yml**
- PR review automation
- **Recommend:** Review and keep if useful

### Documentation

All documentation looks good and up-to-date:
- ✅ README.md
- ✅ QUICKSTART.md
- ✅ PRESENTATION.md
- ✅ docs/AI-SELF-HEALING.md
- ✅ docs/WORKFLOW-COMPARISON.md
- ✅ docs/ARCHITECTURE.md
- ✅ docs/DEMO.md
- ✅ docs/PHASE1-SUMMARY.md

## Post-Cleanup Verification

```bash
# Ensure workflow still works
git push origin main

# Check Actions tab for successful run

# Verify no broken links
grep -r "terraform-ci.yml" docs/ README.md
grep -r "terraform-to-visual.yml" docs/ README.md
```

## Estimated Impact

- **Files removed:** 6-8
- **Risk level:** Low (all deprecated or temporary)
- **Benefit:** Cleaner repo, less confusion
- **Time:** 5 minutes

## Decision Matrix

| File | Status | Action | Priority |
|------|--------|--------|----------|
| terraform-ci.yml | Deprecated | Archive | High |
| terraform-to-visual.yml | Deprecated | Archive | High |
| fix_tests.py | Temporary | Remove | High |
| test_output.log | Temporary | Remove | High |
| intentional_bug_test.go | Old test | Remove | Medium |
| gemini-dispatch.yml | Separate feature | Review | Low |
| pr-review.yml | Separate feature | Review | Low |
| root *.tf files | Unclear | Verify + Remove | Medium |

## Approval Needed

🔴 **High Priority** (recommend immediate cleanup):
- Old workflows (archive to keep history)
- Temporary scripts

🟡 **Medium Priority** (review then decide):
- Root Terraform files
- Old test files

🟢 **Low Priority** (review when time permits):
- Other workflow files if not actively used

