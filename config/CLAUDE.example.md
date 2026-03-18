# CLAUDE.md Example

This is the required structure for your project's `CLAUDE.md` for workflow-kit v2 to work correctly.

## Required Section

```markdown
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
```

The installer reads `repo_owner` and `repo_name` to configure the workflow.

## Stack Detection (automatic)

The installer auto-detects your stack and sets quality commands:

| Stack | Lint | Test |
|-------|------|------|
| Laravel | `composer lint` | `composer test` |
| WordPress | `composer lint` | `composer test` |
| React/Vue | `npm run lint` | `npm test` |
| Node | `npm run lint` | `npm test` |
| Python | `ruff check .` | `pytest` |

## Full Example

```markdown
# My Project

> Brief description of what this project does.

---

## Kit Configuration

workflow_mode: issues
stack: laravel
stack_extras: [inertia, filament]

repo_owner: myorg
repo_name: myproject

quality:
  test_runner: pest
  lint_command: composer lint
  test_command: composer test
  coverage_min: 80
  coverage_new: 90

agents:
  protected:
    - master-orchestrator
    - issue-executor
    # ... (other protected agents)

---

## Project Context

- **Type:** existing
- **Stack:** Laravel 11 + Inertia + Filament
- **Description:** Internal admin dashboard

## Notes

<!-- Project-specific notes -->
```

## Workflow Modes

| Mode | User Goal | Pipeline |
|------|-----------|----------|
| `scratch` | Build something new | Plan → Build → Commit (no branches) |
| `issues` | Improve existing | Full: SETUP → IMPLEMENT → REVIEW → COMMIT → PR → CLOSE |
| `legacy` | Stabilize / fix | Audit → Migration phases |
