---
name: workflow-rules
description: "Global rules for all workflow agents. Ensures consistency, quality, and proper process. Stack-agnostic."
---

# Workflow Rules

These rules apply to all agents in the workflow-kit system.

## Core Principles

1. **Plan before code** — Present plan, wait for explicit approval
2. **Quality gates mandatory** — Lint + test must pass before commit
3. **Documentation required** — CHANGELOG, README updated when applicable
4. **Conventional commits** — `<type>(<scope>): <description> (#N)`
5. **Issue closure** — Run issue-closer after PR merge

## Workflow Modes

| User Goal | Internal Mode |
|-----------|---------------|
| Build something new | `scratch` |
| Improve existing codebase | `issues` |
| Stabilize / fix issues | `legacy` |

## Commands

| Command | Purpose |
|---------|---------|
| `/ww:init` | Bootstrap project |
| `/ww:discover` | Re-analyze, recommend |
| `/ww:plan` | Plan feature |
| `/ww:do` | Execute (scratch or issue) |
| `/ww:commit` | Quality gates + commit |
| `/ww:audit` | Codebase health |
| `/ww:arch` | Architecture decisions |
| `/ww:improve` | Fix workflow issues |

## Pipeline

```
SETUP → IMPLEMENT → REVIEW+QUALITY (parallel) → COMMIT → PR → CLOSE
```

## Quality Gates

Run after file edits:
```bash
[quality.lint_command]
```

Run before commit:
```bash
[quality.test_command]
```

### Tiered Gates

| Change Type | Lint | Tests |
|-------------|------|-------|
| Docs only | ✓ | ✗ |
| Config only | ✓ | ✗ |
| Refactor | ✓ | ✓ (maintain) |
| Feature/Fix | ✓ | ✓ |

## Pre-Flight

Before implementation:
- [ ] Read CLAUDE.md
- [ ] Load relevant `.workflow/patches/`
- [ ] Read relevant `.workflow/ADRs/`
- [ ] Validate issue labels

## Error Handling

| Failure | Strategy | Retries |
|---------|----------|---------|
| Lint | Auto-fix | 1 |
| Flaky test | Retry different seed | 2 |
| Type error | Escalate | 0 |
| Logic error | Back to implement | 0 |

**STOP if existing test breaks. Never commit broken tests.**

## Commit Format

```
<type>(<scope>): <description> (#N)
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Interactive Checkpoints

Before commit:
```
AskUserQuestion: "Review changes?"
→ Approve all | Review each file | Cancel

AskUserQuestion: "Create commit?"
→ Yes | Edit message | Cancel
```

## Protected Agents

Cannot remove without `--force`:
- master-orchestrator, issue-executor, issue-creator
- issue-closer, agent-installer, project-analyst, feature-planner

## Security

- Use array syntax for shell execution — never string interpolation
- Never commit secrets
- Use `.env` for config, ensure in `.gitignore`
