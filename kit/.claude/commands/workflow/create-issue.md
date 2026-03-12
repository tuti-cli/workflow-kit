# workflow:create-issue

> Create a well-formed GitHub issue from current context.

**Usage:**
- `/workflow:create-issue` — Auto-detect context
- `/workflow:create-issue --plan` — From `.workflow/PLAN.md`
- `/workflow:create-issue --adr` — From latest ADR
- `/workflow:create-issue --patch <file>` — From specific patch
- `/workflow:create-issue --execute` — Create and immediately execute

**Issue Template:**
```markdown
## Summary
[What needs to be done]

## Context
[Why this matters]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Technical Notes
[Stack details, constraints]

## Definition of Done
- [ ] Code written and tested
- [ ] Docs updated
- [ ] Issue closed with summary

<!-- WORKFLOW META -->
workflow_type: feature|bugfix|refactor|task
estimated_complexity: small|medium|large
```

Invoke `issue-creator`:
> "GITHUB REPO: owner={{GITHUB_OWNER}} repo={{GITHUB_REPO}}. Create a GitHub issue from current workflow context. IF --plan: read .workflow/PLAN.md. IF --adr: read latest .workflow/ADRs/*.md. IF --patch: read specified patch file. IF no flag: determine context automatically from recent work. Apply correct labels (type:*, priority:*, status: ready). Format body to standard template. Create issue via GitHub MCP or gh CLI with --repo {{GITHUB_OWNER}}/{{GITHUB_REPO}}. Return issue number. IF --execute: immediately invoke /workflow:issue with new issue number."
