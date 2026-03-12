# workflow-kit

A portable AI development workflow system for Claude Code that provides issue-to-PR pipeline automation with quality gates.

## Overview

**workflow-kit** transforms how developers work with Claude Code by automating the complete development lifecycle:

- **Issue-to-PR Automation**: From GitHub issue to merged PR with minimal manual intervention
- **Quality Gates**: Automatic linting and testing enforcement at every step
- **Agent-Based Execution**: Specialized AI agents selected based on issue type
- **Conventional Commits**: Enforced commit format with interactive checkpoints

## Repository Structure

```
workflow-kit/
├── install.sh                      # Main installer/updater script
├── kit/
│   ├── .claude/
│   │   ├── agents/                 # Core agents (6 files)
│   │   │   ├── master-orchestrator.md
│   │   │   ├── issue-executor.md
│   │   │   ├── issue-creator.md
│   │   │   ├── issue-closer.md
│   │   │   ├── agent-installer.md
│   │   │   └── workflow-orchestrator.md
│   │   ├── commands/
│   │   │   ├── workflow/           # /workflow:* commands (7 files)
│   │   │   │   ├── init.md
│   │   │   │   ├── issue.md
│   │   │   │   ├── commit.md
│   │   │   │   ├── create-issue.md
│   │   │   │   ├── status.md
│   │   │   │   ├── update.md
│   │   │   │   └── discover.md
│   │   │   └── agents/             # /agents:* commands (4 files)
│   │   │       ├── install.md
│   │   │       ├── search.md
│   │   │       ├── list.md
│   │   │       └── remove.md
│   │   └── skills/
│   │       ├── workflow-rules/     # Global workflow rules
│   │       │   └── SKILL.md
│   │       └── issue-template/     # GitHub issue format spec
│   │           └── SKILL.md
│   ├── .github/
│   │   ├── workflows/              # GitHub Actions
│   │   │   ├── auto-assign.yml
│   │   │   └── auto-label.yml
│   │   ├── ISSUE_TEMPLATE/         # Issue templates (5 types)
│   │   └── PULL_REQUEST_TEMPLATE.md
│   ├── scripts/
│   │   └── setup-labels.sh         # Label setup script
│   └── WORKFLOW.md                 # End-user workflow docs
└── config/
    └── CLAUDE.example.md           # Template for end-user CLAUDE.md
```

## Architecture

### Pipeline Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         WORKFLOW PIPELINE                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌──────────┐    ┌───────────┐    ┌───────────────────┐    ┌──────────┐    │
│  │  SETUP   │───▶│ IMPLEMENT │───▶│ REVIEW + QUALITY  │───▶│  COMMIT  │    │
│  │          │    │           │    │     (parallel)    │    │          │    │
│  │ - Branch │    │ - Primary │    │ ┌───────┐┌───────┐│    │ - Diff   │    │
│  │ - Labels │    │   agent   │    │ │Review ││ Lint  ││    │   review │    │
│  │ - Notify │    │ - Squad   │    │ │       ││ Test  ││    │ - Conv.  │    │
│  └──────────┘    └───────────┘    │ └───────┘└───────┘│    │   commit │    │
│                                   └───────────────────┘    └────┬─────┘    │
│                                                                 │          │
│                                                                 ▼          │
│                                                           ┌──────────┐    │
│                                                           │    PR    │    │
│                                                           │          │    │
│                                                           │ - Push   │    │
│                                                           │ - Draft  │    │
│                                                           │ - Ready  │    │
│                                                           └────┬─────┘    │
│                                                                │          │
│                                                                ▼          │
│                                                           ┌──────────┐    │
│                                                           │  CLOSE   │    │
│                                                           │          │    │
│                                                           │ - Summar │    │
│                                                           │ - Close  │    │
│                                                           │ - Clean  │    │
│                                                           └──────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Component Relationships

```
User Command                    Agent Coordination
─────────────                   ──────────────────
/workflow:issue N  ────────────▶ issue-executor ───────▶ master-orchestrator
                         │              │                        │
                         │              ▼                        ▼
                         │        - Fetch issue           - Form squad
                         │        - Validate              - Execute pipeline
                         │        - Load context          - Enforce quality
                         │        - Hand off              - Interactive commits
                         │
                         ▼
/workflow:commit   ────────────▶ master-orchestrator (direct)
                         │
                         ▼
/agents:install    ────────────▶ agent-installer
/agents:search     ────────────▶ agent-installer
/agents:list       ────────────▶ (lists installed agents)
```

### Template Variable System

All files in `kit/.claude/` use placeholders that get replaced during installation:

| Variable | Replaced With | Example |
|----------|---------------|---------|
| `{{GITHUB_OWNER}}` | GitHub org/user | `tuti-cli` |
| `{{GITHUB_REPO}}` | Repository name | `my-project` |
| `{{STACK}}` | Detected stack | `laravel`, `react`, `python` |
| `{{QUALITY_GATE_LINT}}` | Lint command | `composer lint` |
| `{{QUALITY_GATE_TEST}}` | Test command | `composer test` |

## Core Components

### Agents

| Agent | File | Model | Purpose |
|-------|------|-------|---------|
| **master-orchestrator** | `agents/master-orchestrator.md` | opus | Central brain coordinating all agents, pipeline execution, quality gates |
| **issue-executor** | `agents/issue-executor.md` | sonnet | Entry point for issue workflows, validation, context enrichment |
| **issue-creator** | `agents/issue-creator.md` | sonnet | Creates GitHub issues from plans, ADRs, patches |
| **issue-closer** | `agents/issue-closer.md` | haiku | Closes issues with summary comments, cleanup |
| **agent-installer** | `agents/agent-installer.md` | haiku | Installs agents from VoltAgent catalog |
| **workflow-orchestrator** | `agents/workflow-orchestrator.md` | sonnet | Base orchestration patterns, pipeline templates |

### Commands

#### Workflow Commands

| Command | File | Description |
|---------|------|-------------|
| `/workflow:init` | `commands/workflow/init.md` | Initialize workflow-kit in a project |
| `/workflow:issue <N>` | `commands/workflow/issue.md` | Execute issue through full pipeline |
| `/workflow:commit` | `commands/workflow/commit.md` | Create conventional commit with quality gates |
| `/workflow:create-issue` | `commands/workflow/create-issue.md` | Create issue from current context |
| `/workflow:status` | `commands/workflow/status.md` | Show version, config, and state |
| `/workflow:update` | `commands/workflow/update.md` | Pull latest workflow-kit updates |
| `/workflow:discover` | `commands/workflow/discover.md` | Analyze project, recommend agents |

#### Agent Commands

| Command | File | Description |
|---------|------|-------------|
| `/agents:install <name>` | `commands/agents/install.md` | Install agent from VoltAgent catalog |
| `/agents:search <query>` | `commands/agents/search.md` | Search available agents |
| `/agents:list` | `commands/agents/list.md` | List installed agents |
| `/agents:remove <name>` | `commands/agents/remove.md` | Remove installed agent |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| **workflow-rules** | `skills/workflow-rules/` | Global rules for quality gates, labels, conventions |
| **issue-template** | `skills/issue-template/` | GitHub issue format specification |

## Agent Squad Selection

Squads are formed based on issue `type:*` label and content keywords:

### By Type Label

| Type Label | Primary Agent | Secondary Agents |
|------------|---------------|------------------|
| `type: feature` | cli-developer | php-pro, laravel-specialist |
| `type: bug` | error-detective | code-reviewer, qa-expert |
| `type: chore` | refactoring-specialist | code-reviewer |
| `type: security` | security-auditor | code-reviewer |
| `type: performance` | performance-engineer | refactoring-specialist |
| `type: infra` | devops-engineer | deployment-engineer |
| `type: architecture` | architect-reviewer | refactoring-specialist |
| `type: docs` | documentation-engineer | - |
| `type: test` | qa-expert | - |

### By Content Keywords

| Keywords | Additional Agent |
|----------|------------------|
| docker, container, compose | devops-engineer |
| test, coverage, pest, jest | qa-expert |
| refactor, clean, restructure | refactoring-specialist |
| security, vulnerability | security-auditor |
| performance, slow, optimize | performance-engineer |
| database, migration, sql | database-administrator |
| deploy, release, ci/cd | deployment-engineer |
| dependency, composer, npm | dependency-manager |

## Label System

### Type Labels

| Label | Description |
|-------|-------------|
| `type: feature` | New functionality |
| `type: bug` | Bug fix |
| `type: chore` | Refactoring, tooling, dependencies |
| `type: docs` | Documentation |
| `type: security` | Security issue |
| `type: performance` | Performance improvement |
| `type: infra` | Infrastructure/DevOps |
| `type: architecture` | Architecture changes |
| `type: test` | Testing |

### Priority Labels

| Label | Meaning |
|-------|---------|
| `priority: critical` | Production broken, drop everything |
| `priority: high` | Urgent, this sprint |
| `priority: medium` | Normal priority |
| `priority: low` | Nice to have |

### Status Flow

```
needs-confirmation → confirmed → ready → in-progress → review → (closed)
                                          ↓
                                       blocked
```

## Quality Gates

### Tiered Requirements

| Change Type | Lint | Test | When |
|-------------|------|------|------|
| Docs only (`.md`) | ✓ | ✗ | Only markdown changed |
| Config only | ✓ | ✗ | Only config files changed |
| Refactor | ✓ | ✓ | Behavior-preserving changes |
| Feature/Fix | ✓ | ✓ | Default |

### Error Handling

| Failure | Strategy | Retries |
|---------|----------|---------|
| Lint error | Auto-fix with lint command | 1 |
| Flaky test | Retry with different seed | 2 |
| Type error | Escalate to human | 0 |
| Logic error | Back to implementation | 0 |

## Installation Script

The `install.sh` script handles both fresh installs and updates:

### Functions Overview

| Function | Lines | Purpose |
|----------|-------|---------|
| `check_requirements()` | 53-68 | Verify curl/wget, project dir |
| `check_installed()` | 71-80 | Detect existing installation |
| `read_github_config()` | 83-103 | Extract owner/repo from CLAUDE.md |
| `detect_stack()` | 106-167 | Auto-detect tech stack |
| `replace_template_vars()` | 227-237 | Replace placeholders in files |
| `install_file()` | 240-245 | Copy and process single file |
| `update_file()` | 248-281 | Update with override detection |
| `create_directories()` | 284-296 | Create directory structure |
| `install_components()` | 298-346 | Fresh install all components |
| `update_components()` | 348-394 | Update preserving overrides |

### Supported Stack Detection

| Stack | Detection | Lint | Test |
|-------|-----------|------|------|
| Laravel | `composer.json` has `laravel/framework` | `composer lint` | `composer test` |
| Laravel Zero | `composer.json` has `laravel-zero/framework` | `composer lint` | `composer test` |
| WordPress | `wp-config.php` or `wp-load.php` | `composer lint` | `composer test` |
| React | `package.json` has `react` | `npm run lint` | `npm test` |
| Vue | `package.json` has `vue` | `npm run lint` | `npm test` |
| Node | `package.json` (fallback) | `npm run lint` | `npm test` |
| Python | `requirements.txt` or `pyproject.toml` | `ruff check .` | `pytest` |

## Development Guidelines

### Adding a New Agent

1. Create file in `kit/.claude/agents/<name>.md`
2. Use required frontmatter format:

```markdown
---
name: agent-name
description: "Description of what this agent does"
github:
  owner: {{GITHUB_OWNER}}
  repo: {{GITHUB_REPO}}
  full: {{GITHUB_OWNER}}/{{GITHUB_REPO}}
tools: Read, Write, Edit, Bash, Glob, Grep
model: opus|sonnet|haiku
---

Agent instructions here...
```

3. Reference template variables where needed
4. Update master-orchestrator if agent should be in squads

### Adding a New Command

1. Create file in appropriate subdirectory:
   - `kit/.claude/commands/workflow/<name>.md` for workflow commands
   - `kit/.claude/commands/agents/<name>.md` for agent commands
2. Follow command format:

```markdown
# namespace:command

> Brief description of what this command does.

**Usage:**
- `/namespace:command` — Basic usage
- `/namespace:command --option` — With option

Invoke `<agent-name>`:
> "Instruction for the agent with $ARGUMENTS placeholder"
```

### Adding a New Skill

1. Create directory: `kit/.claude/skills/<skill-name>/`
2. Create `SKILL.md` with frontmatter:

```markdown
---
name: skill-name
description: "Skill description"
---

Skill content here...
```

### Adding Stack Detection

Edit `detect_stack()` function in `install.sh` (lines 106-167):

```bash
# Add new stack detection
if [ -f "$PROJECT_ROOT/some-indicator-file" ]; then
    STACK="new-stack"
    QUALITY_GATE_LINT="new-lint-command"
    QUALITY_GATE_TEST="new-test-command"
fi
```

### Modifying Pipeline Stages

Edit `master-orchestrator.md` (lines 97-194) to change:
- Branch validation logic
- Stage actions
- Commit checkpoints
- PR creation flow

## Extension Points

### 1. New Pipeline Types

Add to `master-orchestrator.md` Pipeline Selection Matrix:

```markdown
| Label | Pipeline |
|-------|---------|
| `workflow:new-type` | New Pipeline |
```

### 2. New Quality Gates

Add tiered gates to `workflow-rules/SKILL.md` and `master-orchestrator.md`.

### 3. New Agent Squad Configurations

Update Agent Squad Selection tables in:
- `master-orchestrator.md` (lines 68-96)
- `commands/workflow/issue.md` (lines 21-31)
- `skills/workflow-rules/SKILL.md` (lines 28-42)

### 4. New Issue Templates

Create new template in `kit/.github/ISSUE_TEMPLATE/` following existing patterns.

## GitHub Repository Configuration

### Repository

- **Owner:** tuti-cli
- **Repo:** workflow-kit
- **Full:** tuti-cli/workflow-kit
- **gh CLI:** Always use `--repo tuti-cli/workflow-kit`
- **GitHub MCP:** Always use `owner="tuti-cli" repo="workflow-kit"`

### Protected Agents

Core agents cannot be removed without `--force`:
- master-orchestrator
- issue-executor
- issue-creator
- issue-closer
- agent-installer
- workflow-orchestrator

## Quality Gates for This Repository

### Lint
```bash
shellcheck install.sh kit/scripts/setup-labels.sh
```

### Test
Manual testing of installer:
1. Fresh install in test directory
2. Update from previous version
3. Template variable replacement verification
4. Stack detection accuracy

### Documentation Sync
Ensure these stay synchronized:
- `config/CLAUDE.example.md` - End-user template
- `kit/WORKFLOW.md` - End-user docs
- This file - Developer docs

## Key Files for Common Tasks

| Task | Primary File | Related Files |
|------|--------------|---------------|
| Change pipeline stages | `kit/.claude/agents/master-orchestrator.md` | - |
| Add stack detection | `install.sh:106-167` | - |
| Modify quality gates | `kit/.claude/skills/workflow-rules/SKILL.md` | `master-orchestrator.md` |
| Change label system | `kit/.claude/skills/workflow-rules/SKILL.md` | `master-orchestrator.md` |
| Add new command | `kit/.claude/commands/*/` | - |
| Update installer behavior | `install.sh` | - |
| Change issue validation | `kit/.claude/agents/issue-executor.md` | `skills/issue-template/SKILL.md` |
| Modify agent squads | `kit/.claude/agents/master-orchestrator.md:68-96` | - |

## Commit Format

```
<type>(<scope>): <description>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Security

- Use array syntax for all process/shell execution — never string interpolation
- Never commit secrets or credentials
- Template variables must not expose sensitive information
- Installer should fail gracefully on missing dependencies
