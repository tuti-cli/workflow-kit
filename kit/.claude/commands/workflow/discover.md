# ww:discover

> Analyze project, detect stack, and recommend skills to install.

**Usage:**
- `/ww:discover` — Analyze current directory
- `/ww:discover <file>` — Analyze a discovery document

**What it does:**
1. Detects technology stack (languages, frameworks, databases)
2. Identifies quality gate commands (lint, test)
3. Loads recommendations from `.claude/config/recommendations.json` for detected stack
4. Checks which recommended skills are already installed — skips them
5. Shows a menu of missing skills with descriptions — user picks which to install
6. Invokes `skill-generator` for each chosen skill
7. Updates `.claude/rules/project/stack.md` with detected stack info
8. Creates `.workflow/PROJECT.md` with project documentation

**Output:**
- `.workflow/PROJECT.md` — project architecture, conventions, quality gates
- New skill/rule files in `.claude/skills/` and `.claude/rules/project/`

Invoke `skill-generator` for the full discover flow:
> "GITHUB REPO: owner={{GITHUB_OWNER}} repo={{GITHUB_REPO}}. Run project discovery. IF file argument provided: read '$ARGUMENTS' as discovery doc. ELSE: analyze codebase — read composer.json, package.json, requirements.txt, wp-config.php, directory structure. Steps: (1) Detect stack (laravel/react/vue/wordpress/node/python/generic), frameworks, databases, test runner, lint/test commands. (2) Fetch the full VoltAgent catalog from https://raw.githubusercontent.com/VoltAgent/awesome-claude-code-subagents/main/README.md — parse all categories and entries. (3) Based on detected stack, filter and suggest the most relevant entries (e.g. for Laravel: laravel-specialist, php-pro, security-auditor, qa-expert; for React: react-specialist, typescript-pro, frontend-developer). (4) Check which suggested skills already exist in .claude/rules/ and .claude/skills/ — mark as installed, skip them. (5) Present remaining suggestions as a numbered menu grouped by category with names and descriptions. Ask: 'Which skills do you want to install? Enter numbers, or type a name to search the full catalog'. (6) For each chosen entry, run the skill generation flow: fetch VoltAgent source as brief, read project context, generate project-specific skill/rule file. (7) Update .claude/rules/project/stack.md with stack, versions, lint command, test command. (8) Create .workflow/PROJECT.md documenting stack, conventions, quality gates, architecture overview. (9) Update CLAUDE.md GitHub Repository section if owner/repo not present. Report all generated files."
