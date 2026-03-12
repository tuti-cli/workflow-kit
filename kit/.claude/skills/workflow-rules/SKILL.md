---
name: workflow-rules
description: "Global rules that all workflow agents must follow. Ensures consistency, quality, and proper process across all pipeline executions. Stack: {{STACK}}."
---

# Workflow Rules

These rules apply to all agents in this project's workflow system.

## Project Configuration

- **Stack:** {{STACK}}
- **Lint:** `{{QUALITY_GATE_LINT}}`
- **Test:** `{{QUALITY_GATE_TEST}}`
- **GitHub:** {{GITHUB_OWNER}}/{{GITHUB_REPO}}
- **gh CLI:** Always use `--repo {{GITHUB_OWNER}}/{{GITHUB_REPO}}`
- **GitHub MCP:** Always use `owner="{{GITHUB_OWNER}}" repo="{{GITHUB_REPO}}"`

## Core Principles

1. **Plan before code** — Always present plan, wait for explicit approval
2. **Quality gates are mandatory** — Lint + test must pass before any commit
3. **Documentation is required** — CHANGELOG, README, inline docs updated
4. **Conventional commits only** — `<type>(<scope>): <description> (#N)`
5. **Every issue must close** — Post summary, run issue-closer after PR merge

## Label System

### Type Labels (drives agent selection)

| Label | Meaning | Primary Agent |
|-------|---------|--------------|
| `type: feature` | New feature | cli-developer |
| `type: bug` | Bug fix | error-detective |
| `type: chore` | Refactor, tooling, deps | refactoring-specialist |
| `type: docs` | Documentation | documentation-engineer |
| `type: security` | Security issue | security-auditor |
| `type: performance` | Performance | performance-engineer |
| `type: infra` | Infrastructure | devops-engineer |
| `type: architecture` | Architecture | architect-reviewer |
| `type: test` | Testing | qa-expert |

### Priority Labels

| Label | Meaning |
|-------|---------|
| `priority: critical` | Drop everything — production broken |
| `priority: high` | Urgent, this sprint |
| `priority: medium` | Normal priority |
| `priority: low` | Nice to have |

### Status Labels

| Label | Board Column | Meaning |
|-------|-------------|---------|
| `status: needs-confirmation` | 🔶 Inbox | External issue, needs triage |
| `status: confirmed` | ✅ Confirmed | Triaged, awaiting grooming |
| `status: ready` | 📋 Ready | Groomed, ready to pick up |
| `status: in-progress` | 🔨 In Progress | Being worked on |
| `status: blocked` | 🚫 Blocked | Waiting on external |
| `status: review` | 👀 In Review | PR open |
| `status: rejected` | ❌ Rejected | Will not implement |
| *(closed)* | ✅ Done | PR merged |

## Pipeline

```
SETUP → IMPLEMENT → REVIEW+QUALITY (parallel) → COMMIT → PR → CLOSE
```

## Quality Gates

Run **after every file edit:**
```bash
{{QUALITY_GATE_LINT}}
```

Run **before every commit:**
```bash
{{QUALITY_GATE_TEST}}
```

### Tiered Gates

| Change Type | Lint | Tests |
|-------------|------|-------|
| Docs only (`.md`) | ✓ | ✗ |
| Config only | ✓ | ✗ |
| Refactor | ✓ | ✓ (maintain) |
| Feature / Fix | ✓ | ✓ |

## Pre-Flight Checklist

Before any implementation:
- [ ] Read CLAUDE.md
- [ ] Load relevant patches via `.workflow/patches/INDEX.md`
- [ ] Read relevant `.workflow/ADRs/`
- [ ] Validate issue has required labels and sections
- [ ] Auto-label if missing (AskUserQuestion to confirm)

## Selective Patch Loading

1. Read `.workflow/patches/INDEX.md` first
2. Match issue keywords to categories:

| Keywords | Category |
|----------|---------|
| docker, container, compose | docker |
| test, coverage, pest, jest | testing |
| security, vulnerability | security |
| refactor, clean | refactor |
| workflow, pipeline, agent | workflow |

3. Load only matching category patches
4. Full load if INDEX is stale (>24h)

## Error Handling

### Smart Retry

| Failure | Strategy | Retries |
|---------|----------|---------|
| Lint | Auto-fix with lint command | 1 |
| Flaky test | Retry different seed | 2 |
| Type error | Escalate to human | 0 |
| Logic error | Back to implementation | 0 |

**Existing test breaks → STOP IMMEDIATELY. Do not commit.**

## Commit Format

```
<type>(<scope>): <description> (#N)
```

Types: `feat` `fix` `docs` `style` `refactor` `test` `chore`

## Interactive Checkpoints

**Before commit:**
```
AskUserQuestion: "Review changes?"
→ Approve all | Review each file | Cancel

AskUserQuestion: "Create commit?"
→ Yes | Edit message | Cancel
```

## Protected Agents

Cannot be removed without `--force`:
- master-orchestrator, issue-executor, issue-creator
- issue-closer, agent-installer, workflow-orchestrator

## Security

- Use array syntax for all process/shell execution — never string interpolation
- Never commit secrets or credentials
- Use `.env` for configuration, ensure it's in `.gitignore`
