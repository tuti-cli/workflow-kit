# Development Workflow

> Powered by [workflow-kit](https://github.com/tuti-cli/workflow-kit)

## Quick Reference

| Command | What it does |
|---------|-------------|
| `/workflow:issue <N>` | Implement issue end-to-end (plan → code → PR) |
| `/workflow:issue <N> --dry-run` | Show plan only, no execution |
| `/workflow:issue <N> --worktree` | Implement in isolated worktree |
| `/workflow:commit` | Create conventional commit with quality gates |
| `/workflow:create-issue` | Create GitHub issue from current context |
| `/workflow:discover` | Analyze project, recommend agents |
| `/workflow:status` | Show version, config, state |
| `/workflow:update` | Pull latest workflow-kit updates |
| `/agents:install <n>` | Install agent from VoltAgent catalog |
| `/agents:search <query>` | Search available agents |
| `/agents:list` | List installed agents |

## Issue Lifecycle

```
External issue → status: needs-confirmation → /triage → status: confirmed → status: ready
New feature/bug → create with template → status: ready
                                              ↓
                                    /workflow:issue <N>
                                              ↓
                                    Plan mode (approval required)
                                              ↓
                                    Branch created
                                              ↓
                                    Agent squad implements
                                              ↓
                                    After each edit: lint
                                              ↓
                                    Before commit: lint + test
                                              ↓
                                    Commit → Push → PR
                                              ↓
                                    You review and merge
                                              ↓
                                    Issue auto-closes (Closes #N)
```

## Label System

### Type → Agent Selection

| Label | Primary Agent |
|-------|--------------|
| `type: feature` | cli-developer |
| `type: bug` | error-detective |
| `type: chore` | refactoring-specialist |
| `type: docs` | documentation-engineer |
| `type: security` | security-auditor |
| `type: performance` | performance-engineer |
| `type: infra` | devops-engineer |
| `type: architecture` | architect-reviewer |
| `type: test` | qa-expert |

### Status Flow

| Label | Board Column | When |
|-------|-------------|------|
| `status: needs-confirmation` | 🔶 Inbox | External issue, needs triage |
| `status: confirmed` | ✅ Confirmed | Triaged, not yet groomed |
| `status: ready` | 📋 Ready | Groomed, ready to implement |
| `status: in-progress` | 🔨 In Progress | Being worked on |
| `status: blocked` | 🚫 Blocked | Waiting on external dependency |
| `status: review` | 👀 In Review | PR open |
| `status: rejected` | ❌ Rejected | Will not implement |
| *(closed)* | ✅ Done | PR merged |

### Priority

`priority: critical` → `priority: high` → `priority: medium` → `priority: low`

## Branch Naming

```
feature/<N>-short-description
fix/<N>-short-description
chore/<N>-short-description
docs/<N>-short-description
security/<N>-short-description
```

## Commit Format

```
<type>(<scope>): <description> (#N)
```

Types: `feat` `fix` `docs` `style` `refactor` `test` `chore`

## Rules

- **Every task starts with a GitHub issue** — no issue, no branch, no PR
- **Plan before code** — agent always presents plan and waits for approval
- **Quality gates must pass** — lint + test before every commit
- **No direct main commits** — always branch + PR
- **One issue per branch** — keep scope tight
- **Do not amend commits** — create new commits to fix issues
- **Do not force push** to shared branches

## Improving the Workflow

```
/workflow:issue N   ← where N is a chore issue describing the improvement
```

Or use `/workflow:create-issue` to create the improvement issue first.

## Directory Structure

```
.claude/
├── agents/           # Core + installed specialist agents
├── commands/         # Slash commands
│   ├── workflow/     # /workflow:* commands
│   └── agents/       # /agents:* commands
└── skills/
    ├── workflow-rules/   # Global rules (quality gates, labels, conventions)
    └── issue-template/   # Issue format spec

.workflow/
├── .base-version     # Version tracking
├── patches/          # Bug fix lessons (accumulate over time)
│   └── INDEX.md      # Categorized index for selective loading
├── ADRs/             # Architecture decisions (permanent)
├── features/         # Active feature plans (cleaned up after close)
└── state/            # Runtime state per issue
```

## Setup (New Project)

```bash
# 1. Install workflow-kit
curl -sL https://raw.githubusercontent.com/tuti-cli/workflow-kit/main/install.sh | bash

# 2. Create GitHub labels
chmod +x scripts/setup-labels.sh
./scripts/setup-labels.sh

# 3. Analyze project, get agent recommendations
# In Claude Code:
/workflow:discover

# 4. Install recommended specialist agents
/agents:install php-pro
/agents:install laravel-specialist
# etc.
```

## Update

```bash
curl -sL https://raw.githubusercontent.com/tuti-cli/workflow-kit/main/install.sh | bash
```

Or in Claude Code: `/workflow:update`
