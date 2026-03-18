# workflow-kit v2

> A portable AI development workflow system for Claude Code. Install in any project and get intelligent automation with quality gates, three workflow modes, and knowledge capture.

## Installation

```bash
curl -sL https://raw.githubusercontent.com/tuti-cli/workflow-kit/main/install.sh | bash
```

Or specify a project directory:

```bash
curl -sL https://raw.githubusercontent.com/tuti-cli/workflow-kit/main/install.sh | bash -s -- /path/to/project
```

The installer will:
1. Create `.claude/` structure with agents, commands, skills, and rules
2. Create `.workflow/` structure for artifacts (plans, audits, ADRs, patches)
3. Configure from your `CLAUDE.md`
4. Set up version tracking for updates

## Quick Start

```bash
# 1. Set up GitHub labels
./scripts/setup-labels.sh

# 2. Analyze project, get recommendations
/ww:discover

# 3. Plan a feature
/ww:plan

# 4. Execute
/ww:do
```

## Workflow Modes

| Mode | User Goal | Pipeline |
|------|-----------|----------|
| `scratch` | Build something new | Plan → Build → Commit (no branches) |
| `issues` | Improve existing | Full: SETUP → IMPLEMENT → REVIEW → COMMIT → PR → CLOSE |
| `legacy` | Stabilize / fix | Audit → Migration phases |

## Commands

| Command | Purpose |
|---------|---------|
| `/ww:init` | Bootstrap project |
| `/ww:discover` | Analyze, recommend agents & rules |
| `/ww:plan` | Plan feature with tasks |
| `/ww:do` | Execute (scratch mode) |
| `/ww:do N` | Execute issue #N (issues mode) |
| `/ww:commit` | Quality gates + commit |
| `/ww:audit` | Codebase health check |
| `/ww:arch` | Architecture decisions |
| `/ww:improve` | Fix workflow issues |
| `/agents:install <name>` | Install specialist agent |
| `/rules:add project "..."` | Add project rule |

## What's Included

### Core Agents (12)
| Agent | Model | Purpose |
|-------|-------|---------|
| `master-orchestrator` | opus | Pipeline coordinator |
| `issue-executor` | sonnet | Issue validation & enrichment |
| `project-analyst` | sonnet | Init/discover/recommend |
| `feature-planner` | sonnet | Task breakdown & estimation |
| `codebase-auditor` | opus | Audit & debt mapping |
| `migration-planner` | sonnet | Legacy migration |
| `architecture-lead` | opus | Brainstorm & ADR |
| `architecture-challenger` | sonnet | Stress-test proposals |
| `issue-creator` | sonnet | Create issues from artifacts |
| `issue-closer` | haiku | Close & archive |
| `agent-installer` | sonnet | Catalog install & adapt |
| `patch-writer` | haiku | Bug fix knowledge capture |

### Rules (3 layers)
- `.claude/rules/base/` — Coding standards, git, testing, architecture
- `.claude/rules/project/` — Stack, conventions, architecture decisions
- `.claude/rules/features/` — Subsystem overrides (auth, payments, etc.)

### Artifacts
- `.workflow/PLAN.md` — Active feature plan
- `.workflow/AUDIT.md` — Codebase health
- `.workflow/TECH-DEBT.md` — Debt registry
- `.workflow/ADRs/` — Architecture decisions
- `.workflow/patches/` — Bug fix knowledge

## Update

```bash
curl -sL https://raw.githubusercontent.com/tuti-cli/workflow-kit/main/install.sh | bash
```

Options:
- `--check` - Check for updates
- `--force` - Discard overrides

## Requirements

### CLAUDE.md Configuration

Your project's `CLAUDE.md` needs a Kit Configuration section:

```markdown
## Kit Configuration

workflow_mode: scratch        # scratch | issues | legacy
stack: laravel                # laravel | vue | react | ...

repo_owner: your-org          # GitHub org or username
repo_name: your-repo         # Repository name

quality:
  test_runner: pest
  lint_command: composer lint
  test_command: composer test
  coverage_min: 80
```

## Directory Structure

```
your-project/
├── CLAUDE.md                 # Kit Configuration required
├── .claude/
│   ├── agents/               # Core + installed agents
│   ├── commands/
│   │   ├── workflow/        # /ww:* commands
│   │   ├── agents/          # /agents:* commands
│   │   └── rules/           # /rules:* commands
│   ├── skills/              # workflow-rules, issue-template
│   └── rules/               # base/, project/, features/
└── .workflow/
    ├── PLAN.md              # Active plan
    ├── AUDIT.md             # Health check
    ├── TECH-DEBT.md         # Debt registry
    ├── ADRs/                # Architecture decisions
    ├── patches/             # Bug fix knowledge
    └── features/            # Archived plans
```

## License

MIT
