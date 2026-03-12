# workflow:discover

> Analyze project to detect stack, set up workflow config, recommend agents.

**Usage:**
- `/workflow:discover` — Analyze current directory
- `/workflow:discover <file>` — Analyze a discovery document

**What it does:**
1. Detects technology stack (languages, frameworks, databases)
2. Identifies quality gate commands (lint, test)
3. Recommends specialist agents from VoltAgent catalog
4. Updates CLAUDE.md with GitHub Repository section if missing
5. Creates `.workflow/PROJECT.md` with full project documentation
6. Lists recommended agents to install

**Output:**
- `.workflow/PROJECT.md` — project architecture, conventions, testing config
- Recommended agent list → install with `/agents:install <name>`

Invoke `agent-installer` for catalog access:
> "GITHUB REPO: owner={{GITHUB_OWNER}} repo={{GITHUB_REPO}}. Analyze the project for workflow setup. IF file argument provided: read '$ARGUMENTS'. ELSE: analyze codebase in current directory — read composer.json, package.json, requirements.txt, wp-config.php, directory structure. Detect: stack (laravel/react/vue/wordpress/node/python/generic), frameworks, databases, testing tools, existing lint/test commands. Recommend specific agents from awesome-claude-code-subagents catalog. Create .workflow/PROJECT.md documenting: stack, conventions, quality gates, architecture overview. Update CLAUDE.md GitHub Repository section if owner/repo not present. Present recommended agent list with /agents:install commands."
