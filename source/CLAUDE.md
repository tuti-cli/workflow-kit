# [Project Name]

> Brief one-line description of what this project does.

---

<!-- WORKFLOW-KIT CONFIG — all agents read this block -->
## Kit Configuration

workflow_mode: scratch        # scratch | issues | legacy
stack: laravel                # laravel | vue | react | wordpress | next | nuxt

repo_owner: your-org         # your GitHub org or username
repo_name: your-repo          # your repository name

quality:
  test_runner: pest           # pest | phpunit | vitest | jest | playwright
  lint_command: composer lint # update after /ww:init
  test_command: composer test # update after /ww:init
  coverage_min: 80            # overall minimum %
  coverage_new: 90            # new code minimum %

agents:
  protected:
    - master-orchestrator
    - issue-executor
    - issue-creator
    - issue-closer
    - agent-installer
    - project-analyst
    - feature-planner
    - architecture-lead
    - architecture-challenger
    - codebase-auditor
    - migration-planner
    - patch-writer

<!-- END WORKFLOW-KIT CONFIG -->

---

## Project Context

- **Type:** new | existing | legacy
- **Stack:** [from /ww:discover]
- **Description:** [what this project does]

## Current Workflow State

- **Active Mode:** scratch
- **Active Plan:** none
- **Open Issues:** 0

## Key Commands

```bash
# First time — bootstrap project
/ww:init

# Analyze project, recommend agents
/ww:discover

# Plan a feature
/ww:plan

# Execute (scratch mode)
/ww:do

# Execute (issues mode)
/ww:do 42

# Codebase audit
/ww:audit

# Architecture decisions
/ww:arch

# Fix workflow issues
/ww:improve
```

## Notes

<!-- Project-specific notes -->
