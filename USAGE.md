# Usage Guide

## Installation

### Quick Install

```bash
curl -sL https://raw.githubusercontent.com/tuti-cli/workflow-kit/main/install.sh | bash
```

### Install in a Specific Project

```bash
./install.sh /path/to/my-project
```

### Install Options

```bash
./install.sh --version 1.0.0   # specific version
./install.sh --check            # check for updates only
./install.sh --force            # overwrite modified files
./install.sh --local            # use local kit (development)
```

## First-Time Setup

After installing, run these commands in order:

```
/ww:discover              # detects your stack, recommends skills
/ww:describe docs.md     # creates structured project description (new projects)
/ww:plan                  # creates your first task breakdown
```

## Commands Reference

### Setup & Configuration

#### `/ww:init`
Install workflow-kit into a project. Detects stack, sets quality gates, creates directory structure.

```
/ww:init
/ww:init --owner=myorg --repo=myapp
```

#### `/ww:discover`
Analyze project and recommend skills/agents/rules to install.

```
/ww:discover                    # quick: detect stack, recommend
/ww:discover project-docs.md   # analyze discovery document
/ww:discover --deep             # deep: audit + goals + recommendations
```

#### `/ww:status`
Show current workflow-kit version, configuration, and project state.

```
/ww:status
```

#### `/ww:update`
Pull latest workflow-kit updates.

```
/ww:update            # check and apply
/ww:update --check    # check only
/ww:update --force    # overwrite all files
```

### Planning & Description

#### `/ww:describe`
Transform raw client/project documents into a structured project description. Grills requirements before accepting them.

```
/ww:describe project-discovery.md    # from document
/ww:describe --from-issue 42          # from GitHub issue
```

Output: `.workflow/core/PROJECT.md`

#### `/ww:plan`
Create a task breakdown with priorities. Grills the plan before finalizing.

```
/ww:plan                  # interactive planning
/ww:plan --issue 42       # plan from GitHub issue
/ww:plan --plan-only      # create plan, don't execute
/ww:plan --estimate       # include time estimates
```

Output: `.workflow/core/PLAN.md`

### Execution

#### `/ww:do`
Execute a plan. The main execution command.

```
/ww:do                  # scratch mode: execute from PLAN.md
/ww:do 42               # issues mode: execute from GitHub issue #42
/ww:do --dry-run        # show what would happen
/ww:do --worktree       # run in isolated git worktree
/ww:do --quick          # skip review, minimal quality checks
```

#### `/ww:commit`
Run quality gates, review diff, create conventional commit.

```
/ww:commit                    # interactive: lint, test, diff, commit
/ww:commit "feat: add auth"   # with specified message
/ww:commit --pr               # commit + push + create PR
```

### Analysis & Architecture

#### `/ww:audit`
Codebase health check. Produces AUDIT.md and TECH-DEBT.md.

```
/ww:audit               # standard health check
/ww:audit --legacy      # deep legacy analysis for migration
/ww:audit --debt-only   # update tech debt from existing audit
```

Output: `.workflow/analysis/AUDIT.md`, `.workflow/analysis/TECH-DEBT.md`

#### `/ww:arch`
Architecture decisions: brainstorm options, challenge proposals, record decisions.

```
/ww:arch brainstorm "auth strategy"    # explore 2-3 options
/ww:arch challenge "auth strategy"     # stress-test a proposal
/ww:arch decide "auth strategy"        # lock in decision, write ADR
```

Output: `.workflow/decisions/ADRs/NNN-topic.md`

### Creation

#### `/ww:create`
Generate skills, agents, or GitHub issues. Validates correct type placement using the three-layer model.

```
# Skills (instincts)
/ww:create skill livewire                        # from scratch
/ww:create skill livewire --from vue-expert       # from VoltAgent source
/ww:create skill livewire --global                # install globally

# Agents (workers)
/ww:create agent api-tester                       # from scratch
/ww:create agent api-tester --from qa-expert      # from VoltAgent source
/ww:create agent api-tester --global              # install globally

# Issues
/ww:create issue                    # from current context
/ww:create issue --plan             # from PLAN.md
/ww:create issue --adr              # from latest ADR
/ww:create issue --patch fix.md     # from patch file
/ww:create issue --execute          # create + immediately run
```

### Rules Management

#### `/ww:rules-add`
Add a rule with automatic placement validation. Determines if it's a hard rule (CLAUDE.md) or soft rule (rules/) based on impact.

```
/ww:rules-add project "Always use Form Requests for validation"
/ww:rules-add features/auth "Only use sanctum guards on API routes"
```

#### `/ww:rules-show`
Display active rules organized by priority layer.

```
/ww:rules-show              # all rules
/ww:rules-show hard         # CLAUDE.md rules only
/ww:rules-show base         # base layer
/ww:rules-show project      # project layer
/ww:rules-show features     # feature layers
```

### Self-Improvement

#### `/ww:improve`
Diagnose workflow problems and suggest fixes.

```
/ww:improve
```

Then describe what went wrong. The system analyzes the problem and suggests:
- Rule additions via `/ww:rules-add`
- Skill edits
- Agent adjustments
- Quality gate config fixes

All suggestions require your approval before applying.

## Workflow Patterns

### New Project (Scratch Mode)

```
/ww:init                           # install workflow-kit
/ww:discover                       # detect stack, install skills
/ww:describe project-brief.md     # grill requirements, create PROJECT.md
/ww:plan                           # grill plan, create PLAN.md
/ww:do                             # implement tasks from PLAN.md
/ww:commit                         # quality gates + commit
```

### Existing Project (Issues Mode)

```
/ww:init                           # install workflow-kit
/ww:discover                       # detect stack, install skills
/ww:do 42                          # execute issue #42 through pipeline
/ww:commit --pr                    # commit + create PR
```

### Feature Planning

```
/ww:describe feature-spec.md      # grill the requirements
/ww:plan                           # grill the task breakdown
/ww:create issue --plan            # create GitHub issue from plan
/ww:do 43                          # execute the issue
```

### Architecture Decisions

```
/ww:arch brainstorm "caching"      # explore options
/ww:arch challenge "caching"       # stress-test proposal
/ww:arch decide "caching"          # lock in decision as ADR
```

### Codebase Health

```
/ww:audit                          # standard health check
/ww:audit --legacy                 # legacy analysis for migration
/ww:plan --issue 44                # plan work from audit findings
```

### Quick Fix

```
/ww:do 45 --quick                  # skip review, minimal checks
/ww:commit --pr                    # commit and PR
```

## Automated Mode (Phase 2)

When you're comfortable with the manual commands, use the orchestrator for automated pipeline execution:

```bash
claude --agent master-orchestrator
```

The master-orchestrator:
- Reads your project config and current state
- Drives the full pipeline automatically
- Spawns subagents for parallel work (lint+test, code review, security audit)
- Stops at checkpoints for your approval
- Never proceeds without your explicit "yes"

## File Structure

After installation, your project will have:

```
your-project/
├── CLAUDE.md                      # project config + hard rules
├── WORKFLOW.md                    # this usage guide
├── .claude/
│   ├── agents/                    # worker agents (Phase 2)
│   ├── commands/ww/               # 14 workflow commands
│   ├── rules/
│   │   ├── base/                  # universal rules (always loaded)
│   │   ├── project/               # project-specific rules
│   │   └── features/              # subsystem rules
│   └── skills/
│       ├── workflow/              # workflow behavior
│       ├── stack/                 # stack skills (installed by discover)
│       └── tools/                 # general patterns
├── .workflow/
│   ├── core/                      # STACK.md, PROJECT.md, PLAN.md
│   ├── analysis/                  # AUDIT.md, TECH-DEBT.md
│   ├── decisions/ADRs/            # architecture decision records
│   ├── execution/                 # patches, feature tracking
│   └── meta/                      # proposals, challenges
├── .github/
│   ├── ISSUE_TEMPLATE/            # standardized issue templates
│   ├── workflows/                 # auto-label, auto-assign
│   └── PULL_REQUEST_TEMPLATE.md
└── scripts/
    └── setup-labels.sh            # create GitHub labels
```

## Supported Stacks

Auto-detected during `/ww:init`:

| Stack | Detection | Default Lint | Default Test |
|-------|-----------|-------------|-------------|
| Laravel | `composer.json` has `laravel/framework` | `composer lint` | `composer test` |
| WordPress | `wp-config.php` or `wp-load.php` | `composer lint` | `composer test` |
| React | `package.json` has `react` | `npm run lint` | `npm test` |
| Vue | `package.json` has `vue` | `npm run lint` | `npm test` |
| Next.js | `package.json` has `next` | `npm run lint` | `npm test` |
| Nuxt | `package.json` has `nuxt` | `npm run lint` | `npm test` |
| Node | `package.json` (fallback) | `npm run lint` | `npm test` |
| Python | `requirements.txt` or `pyproject.toml` | `ruff check .` | `pytest` |
| PHP | `composer.json` (fallback) | `composer lint` | `composer test` |

## Quality Gates

Quality gates run automatically before commits. The tier depends on what changed:

| Change Type | Lint | Tests |
|-------------|------|-------|
| Docs only (`.md` files) | Yes | No |
| Config only | Yes | No |
| Refactor | Yes | Yes (maintain existing) |
| Feature / Fix | Yes | Yes |

### When Quality Gates Fail

```
Failure → auto-fix retry (1x) → still failing → report to user
```

| Error Type | Auto-Fix | Retries |
|-----------|----------|---------|
| Lint / format | Run lint auto-fix | 1 |
| Flaky test | Retry different seed | 2 |
| Type error | Stop, show error | 0 |
| Logic error | Stop, back to implementation | 0 |

### Hard Stops

These immediately stop the pipeline:
- Existing test broken by changes
- Type error that can't be auto-fixed
- Coverage dropped below threshold

## Labels System

Run `./scripts/setup-labels.sh` to create standardized labels:

**Workflow labels** (drive pipeline selection):
`workflow:feature`, `workflow:bugfix`, `workflow:refactor`, `workflow:modernize`, `workflow:task`

**Type labels** (describe the work):
`type:feature`, `type:bug`, `type:chore`, `type:docs`, `type:security`, `type:performance`, `type:infra`, `type:test`

**Priority labels**:
`priority:critical`, `priority:high`, `priority:medium`, `priority:low`

**Status labels**:
`status:ready`, `status:in-progress`, `status:review`, `status:blocked`, `status:needs-confirmation`
