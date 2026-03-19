# Git Rules

> Base layer — commit, branch, and PR rules for all projects.

---

## Conventional Commits

Format:
```
<type>(<scope>): <subject> (#N)
```

### Types

| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, whitespace |
| `refactor` | Code restructure, no behaviour change |
| `test` | Adding/updating tests |
| `chore` | Maintenance, dependencies |
| `perf` | Performance improvement |
| `ci` | CI/CD configuration |

### Rules
- Subject line: max 72 characters
- Subject: imperative mood — "add user" not "added user"
- Issue reference `(#N)` required in Issues mode

### Examples

```
feat(auth): add sanctum token authentication (#42)
fix(webhook): handle duplicate event delivery (#87)
refactor(user): extract password reset service (#91)
test(payment): add coverage for failed charges (#103)
```

---

## Branch Naming

| Work Type | Pattern | Example |
|-----------|---------|---------|
| Feature | `feature/<N>-slug` | `feature/42-user-auth` |
| Bug fix | `fix/<N>-slug` | `fix/87-duplicate-webhook` |
| Refactor | `refactor/<N>-slug` | `refactor/91-password-reset` |
| Chore | `chore/<N>-slug` | `chore/55-update-deps` |
| Hotfix | `hotfix/<N>-slug` | `hotfix/99-payment-crash` |

### Rules
- Branch from `main` — never from another branch
- Pull latest before creating branch
- Issue number required in Issues mode

---

## Commit Rules

- **NEVER** create commits automatically — only commit when explicitly requested by the user
- **NEVER** push to remote without explicit user request
- **NEVER** force push or run destructive git commands without explicit approval
- When changes are ready, inform the user and wait for their instruction
- Always show `git diff` or `git status` to let the user review before committing

---

## Pull Requests

### Before PR
- All tests pass locally
- Quality gates pass (lint, types, tests)
- No debug code left in
- Self-reviewed diff

### PR Description
- **NEVER** mention AI tools (Claude, Copilot, Gemini, etc.) in PR title or body
- **NEVER** include change statistics (file count, lines added/removed)
- **NEVER** add test plan checklists — there is no QA team to execute them
- Keep PR descriptions focused on **what** changed and **why**
- Link to issue (`Closes #N`)
- Screenshots if UI changed

### Rules
- Create as draft first, then mark ready
- Never force-push to open PR
- Squash merge to keep history clean

---

## What Must Never Be Committed

```gitignore
.env
.env.*
*.key
storage/logs/
node_modules/
vendor/
*.local
.DS_Store
```

---

## Commit Checkpoints

- Commit every 3-5 completed tasks
- Each checkpoint should pass quality gates
- Use `WIP:` prefix only if committing broken state
