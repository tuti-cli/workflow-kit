# workflow:init

> Initialize workflow-kit in a new or existing project.

**Usage:**
- `/workflow:init` — Interactive initialization
- `/workflow:init --owner=org --repo=name` — With GitHub config

**What it does:**
1. Checks for existing .claude/ directory
2. Creates .claude/ structure (agents/, commands/, skills/)
3. Creates .workflow/ structure (patches/, ADRs/, features/, state/)
4. Downloads latest workflow-kit release from GitHub
5. Extracts agents, commands, skills to project
6. Reads CLAUDE.md GitHub Repository section for config
7. Replaces {{GITHUB_OWNER}}/{{GITHUB_REPO}} template variables
8. Creates .workflow/.base-version with version info

**Directory Structure Created:**
```
.claude/
├── agents/           # 6 core agents
├── commands/
│   ├── workflow/     # 7 commands
│   └── agents/       # 4 commands
└── skills/
    ├── workflow-rules/
    └── issue-template/

.workflow/
├── .base-version     # Version tracking
├── patches/          # Bug fix lessons
├── ADRs/             # Architecture decisions
├── features/         # Feature plans
├── state/            # Runtime state
├── templates/        # Document templates
├── USAGE.md
└── MASTER-REFERENCE.md
```

**Post-Install:**
- Run `/workflow:discover` to analyze project and get agent recommendations
- Run `/agents:search <query>` to find additional agents
- Run `/agents:install <name>` to install recommended agents

**Example:**
```bash
# Interactive initialization
/workflow:init

# With explicit GitHub config
/workflow:init --owner=myorg --repo=myproject
```

**Requirements:**
- CLAUDE.md file with GitHub Repository section (for template replacement)
- curl or wget for downloading
- Internet connection to fetch latest release

**GitHub Repository Section Format:**
```markdown
### GitHub Repository

- **Owner:** myorg
- **Repo:** myproject
- **Full:** myorg/myproject
```

Invoke `issue-executor` for validation context if needed.
