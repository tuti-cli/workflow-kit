# workflow-kit

> A portable AI development workflow system for Claude Code. Install in any project and get issue-to-PR pipeline automation with quality gates.

## Installation

```bash
curl -sL https://raw.githubusercontent.com/tuti-cli/workflow-kit/master/install.sh | bash
```

Or specify a project directory:

```bash
curl -sL https://raw.githubusercontent.com/tuti-cli/workflow-kit/master/install.sh | bash -s -- /path/to/project
```

That's it. The installer will:
1. Create `.claude/` structure with core agents, commands, and skills
2. Create `.workflow/` structure for tracking
3. Configure GitHub integration from your `CLAUDE.md`
4. Set up version tracking for future updates

## Update

Run the same command again - it will detect the existing installation and update:

```bash
curl -sL https://raw.githubusercontent.com/tuti-cli/workflow-kit/master/install.sh | bash
```

Options:
- `--check` - Check for updates without applying
- `--force` - Discard local overrides, use base versions

## What's Included

### Core Agents (6)
| Agent | Purpose |
|-------|---------|
| `master-orchestrator` | Brain of workflow, coordinates all agents |
| `issue-executor` | Entry point for GitHub issues |
| `issue-creator` | Creates GitHub issues from artifacts |
| `issue-closer` | Closes issues with summaries |
| `agent-installer` | Install agents from VoltAgent catalog |
| `workflow-orchestrator` | Base orchestration patterns |

### Commands (11)
| Command | Purpose |
|---------|---------|
| `/workflow:init` | Initialize workflow in project |
| `/workflow:update` | Pull latest from workflow-kit |
| `/workflow:status` | Show version and config |
| `/workflow:issue <N>` | Execute issue through pipeline |
| `/workflow:commit` | Create conventional commit |
| `/workflow:create-issue` | Create issue from context |
| `/workflow:discover` | Analyze project, recommend agents |
| `/agents:install <name>` | Install agent from catalog |
| `/agents:search <query>` | Search available agents |
| `/agents:list` | List installed agents |
| `/agents:remove <name>` | Remove installed agent |

### Skills (2)
| Skill | Purpose |
|-------|---------|
| `workflow-rules` | Global workflow standards |
| `issue-template` | GitHub issue format |

## Requirements

### CLAUDE.md GitHub Section

Your project's `CLAUDE.md` must have a GitHub Repository section:

```markdown
### GitHub Repository

- **Owner:** your-org
- **Repo:** your-repo
- **Full:** your-org/your-repo
```

This is used to configure agents with the correct repository.

## Directory Structure

```
your-project/
├── CLAUDE.md                        # GitHub Repository section required
├── .claude/
│   ├── settings.json                # Project-specific (never touched)
│   ├── agents/                      # Core + installed agents
│   ├── commands/                    # Workflow commands
│   └── skills/                      # Core skills
│
└── .workflow/
    ├── .base-version                # Version tracking
    ├── patches/                     # Bug fix lessons learned
    ├── ADRs/                        # Architecture decisions
    ├── features/                    # Feature plans
    └── state/                       # Runtime state
```

## License

MIT
