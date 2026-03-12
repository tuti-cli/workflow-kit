# workflow:init

> Initialize workflow-kit in a new or existing project.

**Usage:**
- `/workflow:init` — Interactive initialization
- `/workflow:init --owner=org --repo=name` — With explicit GitHub config

**What it does:**
1. Creates `.claude/` structure (agents/, commands/, skills/)
2. Creates `.workflow/` structure (patches/, ADRs/, features/, state/)
3. Downloads latest workflow-kit release
4. Extracts and installs all components
5. Reads CLAUDE.md for GitHub config and replaces template vars
6. Detects stack → sets quality gate commands
7. Runs `scripts/setup-labels.sh` to create GitHub labels
8. Creates `.workflow/.base-version`

**Post-Install:**
```bash
# Create GitHub labels (requires gh auth)
./scripts/setup-labels.sh

# Analyze project and get agent recommendations
/workflow:discover

# Install recommended agents
/agents:install <name>
```

**Requirements:**
- CLAUDE.md with GitHub Repository section
- `gh` CLI authenticated (for label setup)
- curl or wget

> "Run the workflow-kit installer script. If not already downloaded, fetch from https://raw.githubusercontent.com/tuti-cli/workflow-kit/main/install.sh. Execute with project root as target. After install, run /workflow:discover to analyze the project."
