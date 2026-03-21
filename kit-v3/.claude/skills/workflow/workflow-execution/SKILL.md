---
name: workflow-execution
description: "Pipeline execution behavior for workflow-kit commands. Defines quality gates, checkpoints, error handling, and stage sequencing. Apply when any /ww: command runs."
user-invocable: false
---

# Workflow Execution

Pipeline behavior rules for all workflow-kit commands.

## Quality Gates

Run after file edits:
```
[lint command from CLAUDE.md]
```

Run before commit:
```
[test command from CLAUDE.md]
```

### Tiered Gates

| Change Type | Lint | Tests |
|-------------|------|-------|
| Docs only (.md files) | Y | N |
| Config only | Y | N |
| Refactor | Y | Y (maintain existing) |
| Feature/Fix | Y | Y |

## Interactive Checkpoints

Before implementing:
```
Present plan for approval. Wait for explicit "yes" before writing code.
```

Before commit:
```
Show diff. Ask: "Review changes?" -> Approve all | Review each file | Cancel
Ask: "Create commit?" -> Yes | Edit message | Cancel
```

## Error Handling

| Failure | Strategy | Retries |
|---------|----------|---------|
| Lint error | Auto-fix with lint command | 1 |
| Flaky test | Retry with different seed | 2 |
| Type error | Escalate to human | 0 |
| Logic error | Back to implementation | 0 |
| Timeout | Increase timeout, retry | 1 |

## Hard Stops

- Existing test broken -> STOP. Do not commit. Report to user.
- Type error after retry -> STOP. Show detailed error.
- Coverage below threshold -> STOP. Implement missing tests first.

## Pipeline Stages (Issues Mode)

```
SETUP -> IMPLEMENT -> REVIEW+QUALITY -> COMMIT -> PR -> CLOSE
```

### SETUP
- Create branch: `{type}/{N}-{slug}`
- Update issue label to `status:in-progress`
- Post "Workflow started" comment on issue

### IMPLEMENT
- Present plan, wait for approval
- Execute tasks from plan
- Commit checkpoint every 3-5 tasks

### REVIEW + QUALITY (parallel when agents available)
- Lint + test suite
- Code review

### COMMIT
- Self-review complete diff
- Interactive checkpoint
- Conventional commit format

### PR
- Create draft PR via `gh pr create --draft`
- Link to issue (`Closes #N`)
- Mark ready for review

### CLOSE
- Post summary comment on issue
- Archive plan to `.workflow/execution/features/`
- Update issue label to `status:done`
- Close issue

## Workflow Modes

| User Goal | Mode |
|-----------|------|
| Build something new | `scratch` |
| Improve existing codebase | `issues` |

### Scratch Mode
- Execute from PLAN.md
- No branching or PR (unless --pr flag)
- Commit to current branch

### Issues Mode
- Full pipeline with branching, PR, issue tracking
- Requires valid GitHub issue with labels
