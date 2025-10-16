# Archived Workflows

These workflows have been consolidated into `iac-to-visual-ai.yml`.

## Archived Files

### terraform-ci.yml
**Archived:** 2025-10-16  
**Reason:** Basic CI features integrated into unified AI-enhanced workflow  
**Replacement:** `iac-to-visual-ai.yml` (validate-and-plan job)

### terraform-to-visual.yml
**Archived:** 2025-10-16  
**Reason:** Full pipeline integrated with AI self-healing  
**Replacement:** `iac-to-visual-ai.yml` (all jobs)

### pr-review.yml
**Archived:** 2025-10-16  
**Reason:** PR review integrated into main workflow  
**Replacement:** `iac-to-visual-ai.yml` (pr-review job)

### gemini-dispatch.yml
**Archived:** 2025-10-16  
**Reason:** Gemini assistant integrated into main workflow  
**Replacement:** `iac-to-visual-ai.yml` (gemini-assistant job)

## New Unified Workflow

All functionality is now in **`iac-to-visual-ai.yml`** which provides:

✅ Terraform validation and planning  
✅ Test generation and execution  
✅ Diagram generation  
✅ AI-powered self-healing  
✅ PR code review with Gemini  
✅ @gemini-cli comment assistant  
✅ Artifact publishing

## Benefits of Consolidation

- **Single workflow** to maintain instead of 4 separate ones
- **Shared context** between jobs
- **Consistent AI** integration across all stages
- **Reduced duplication** (50% less code)
- **Better performance** with parallel job execution

---

**Note:** These files are kept for reference. Do not activate them as they will conflict with the new unified workflow.

