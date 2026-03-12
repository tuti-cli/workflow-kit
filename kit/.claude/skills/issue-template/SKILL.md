---
name: issue-template
description: "Standard GitHub issue template format for this workflow system. All issues must follow this format for proper pipeline routing and agent auto-selection."
---

# GitHub Issue Template

All issues must follow this format for correct pipeline routing and execution.

## Required Format

```markdown
## Summary
[What needs to be done — 1-2 sentences]

## Context
[Why this matters, background, business value]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Technical Notes
[Stack details, constraints, related issues, implementation hints]

## Definition of Done
- [ ] Code written and working
- [ ] Tests written and passing
- [ ] Review passed
- [ ] Docs updated (CHANGELOG + inline)
- [ ] Issue closed with summary

<!-- WORKFLOW META -->
workflow_type: feature|bugfix|refactor|task
project_type: new|existing|legacy
estimated_complexity: small|medium|large
related_issues: #123, #456
```

## Section Guidelines

### Summary
- 1–2 sentences max
- Start with action verb: Add, Fix, Update, Remove, Refactor
- Be specific about what changes

✅ Good: "Add JWT refresh token support to the auth service"
❌ Bad: "Improve auth"

### Acceptance Criteria
- Specific and testable conditions
- Cover happy path and edge cases
- Each criterion should map to a test

### Technical Notes
- Stack considerations
- Performance or security requirements
- Dependencies on other issues
- Affected files or components

## WORKFLOW META

This section is **required** for pipeline routing. Do not remove.

### workflow_type

| Value | Pipeline |
|-------|---------|
| `feature` | Full feature pipeline with review |
| `bugfix` | Fix + regression test + patch |
| `refactor` | Behavior-preserving, no new tests required |
| `task` | Minimal pipeline, simple atomic task |

### estimated_complexity

| Value | Typical scope |
|-------|-------------|
| `small` | 1–5 files, < 1 day |
| `medium` | 5–15 files, 1–3 days |
| `large` | 15+ files, 3+ days |

## Required Labels

Every issue needs:

**Type (one):** `type: feature` · `type: bug` · `type: chore` · `type: docs` · `type: security` · `type: performance` · `type: infra` · `type: test`

**Priority (one):** `priority: critical` · `priority: high` · `priority: medium` · `priority: low`

**Status (one):** `status: ready` · `status: needs-confirmation` · `status: blocked`

## Validation

If issue is missing required sections or labels, the workflow will:
1. Post a comment listing what is missing
2. NOT proceed with implementation
3. Wait for the issue to be updated

## Complete Example

```markdown
## Summary
Add user authentication with email/password login and session management.

## Context
The application currently has no authentication. This blocks all user-facing
features and is required for the MVP release.

## Acceptance Criteria
- [ ] Users can register with email and password
- [ ] Users can log in with registered credentials
- [ ] Sessions expire after 24 hours
- [ ] Failed logins are rate limited to 5 per minute
- [ ] Users can log out

## Technical Notes
- Related to #100 (user profile) and #102 (permissions)
- Sessions stored in Redis (already configured)
- Rate limiting via built-in middleware

## Definition of Done
- [ ] Code written and working
- [ ] Tests written and passing
- [ ] Review passed
- [ ] Docs updated
- [ ] Issue closed with summary

<!-- WORKFLOW META -->
workflow_type: feature
project_type: existing
estimated_complexity: medium
related_issues: #100, #102
```
