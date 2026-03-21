# workflow-kit

A portable AI development workflow system for Claude Code.

## Quick Start

```bash
# Install
/ww:init

# Analyze project
/ww:discover

# Describe project from docs
/ww:describe project-discovery.md

# Plan features
/ww:plan

# Execute
/ww:do

# Commit
/ww:commit
```

## Commands

| Command | Purpose |
|---------|---------|
| `/ww:init` | Install workflow-kit in a project |
| `/ww:discover` | Analyze stack, recommend skills/agents |
| `/ww:describe` | Raw docs to structured project description |
| `/ww:plan` | Create task breakdown with priorities |
| `/ww:do` | Execute plan (scratch) or issue (issues mode) |
| `/ww:commit` | Quality gates + conventional commit |
| `/ww:audit` | Codebase health check |
| `/ww:arch` | Architecture decisions and ADRs |
| `/ww:improve` | Diagnose and fix workflow problems |
| `/ww:update` | Pull latest workflow-kit updates |
| `/ww:status` | Show version, config, state |
| `/ww:create` | Generate skills, agents, or issues |
| `/ww:rules-add` | Add a rule with placement validation |
| `/ww:rules-show` | Display active rules by layer |

## Workflow Modes

### Scratch Mode
Build from a plan. No GitHub issues required.

```
/ww:describe → /ww:plan → /ww:do → /ww:commit
```

### Issues Mode
Full pipeline from GitHub issue to closed PR.

```
/ww:do 42 → branch → implement → quality → commit → PR → close
```

## Architecture

### Three-Layer Model

| Layer | Purpose | Example |
|-------|---------|---------|
| **Skills** | Instincts — shape behavior | laravel-specialist, clean-code |
| **Agents** | Workers — do a job, report back | security-auditor, code-reviewer |
| **Pipelines** | Steps — deterministic command logic | fetch issue, run lint, commit |

### Validation Rule

When creating something new, ask: "Does this need to think?"
- No → pipeline step (command logic)
- Yes, always same way → skill
- Yes, depends on context → agent

### Orchestrator

Run `claude --agent master-orchestrator` for automated pipeline with checkpoints.
Commands give you manual step-by-step control.

## File Structure

```
.claude/
  agents/           # Real agents (spawned, do a job, die)
  commands/ww/      # 14 commands
  rules/            # Always loaded
    base/           # Git, testing, coding standards
    project/        # Stack config, conventions
    features/       # Subsystem rules
  skills/           # Conditionally loaded
    workflow/       # workflow-execution, grill-me
    stack/          # laravel, vue, react, etc.
    tools/          # clean-code, etc.

.workflow/
  core/             # STACK.md, PROJECT.md, PLAN.md
  analysis/         # AUDIT.md, TECH-DEBT.md
  decisions/ADRs/   # Architecture Decision Records
  execution/        # patches/, features/
  meta/             # proposals/, challenges/
```

## Rules

### Priority (highest to lowest)
1. **Hard rules** — CLAUDE.md (never forgotten)
2. **Feature rules** — rules/features/ (subsystem-specific)
3. **Project rules** — rules/project/ (this project)
4. **Base rules** — rules/base/ (universal)

### Adding Rules
```
/ww:rules-add project "Always use Form Requests"
/ww:rules-add features/auth "Only sanctum on API routes"
```

## Quality Gates

| Change Type | Lint | Tests |
|-------------|------|-------|
| Docs only | Y | N |
| Config only | Y | N |
| Refactor | Y | Y |
| Feature/Fix | Y | Y |
