# workflow:status

> Show workflow-kit status and configuration.

**Usage:**
- `/workflow:status` — Show full status

**Output:**
```
workflow-kit Status
═══════════════════

Installed Version: v1.0.0
Latest Available:  v1.1.0
Update Available:  Yes

GitHub Configuration:
  Owner: myorg
  Repo:  myproject
  Full:  myorg/myproject

Installed Components:
  Agents:  6 core
  Commands: 11 (7 workflow + 4 agents)
  Skills:   2 (workflow-rules, issue-template)

Local Overrides:
  .claude/agents/master-orchestrator.md (modified)

Project-Specific Additions:
  .claude/agents/my-custom-agent.md

Workflow Directory:
  .workflow/patches/  — 3 patches
  .workflow/ADRs/     — 2 decisions
  .workflow/features/ — 1 active feature
```

**What it checks:**
- Current installed version
- Latest available version from GitHub
- GitHub repository configuration
- Override detection (comparing to base)
- Project-specific additions
- Workflow artifacts count

**Exit Codes:**
- 0 — Up to date
- 1 — Update available
- 2 — Not initialized (run /workflow:init)

Invoke `issue-executor` for context if needed.
