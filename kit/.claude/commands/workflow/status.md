# workflow:status

> Show workflow-kit version, configuration, and project state.

**Usage:**
- `/workflow:status` — Full status dashboard

**Output:**
```
workflow-kit Status
═══════════════════

Version:  v1.0.0 (latest: v1.1.0 — update available)
Stack:    laravel
GitHub:   myorg/myrepo

Quality Gates:
  Lint:   composer lint
  Test:   composer test

Agents:   6 core + 4 installed
Commands: 11
Skills:   2

Overrides (modified locally):
  .claude/agents/master-orchestrator.md

Workflow State:
  Patches:  3
  ADRs:     2
  Active:   feature-42.md
```

> "Show workflow-kit status. Read .workflow/.base-version for installed version. Check GitHub API for latest version. Read CLAUDE.md for GitHub config. List .claude/agents/*.md, .claude/commands/**/*.md, .claude/skills/. Check .claude/base/ for override detection. Count .workflow/patches/*.md, .workflow/ADRs/*.md, .workflow/features/*.md. Present formatted status dashboard."
