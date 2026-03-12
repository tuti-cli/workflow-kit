# CLAUDE.md Example

This is the required structure for your project's `CLAUDE.md` for workflow-kit to work correctly.

## Required Section

```markdown
### GitHub Repository

- **Owner:** your-org
- **Repo:** your-repo
- **Full:** your-org/your-repo
- **gh CLI:** Always use `--repo your-org/your-repo`
- **GitHub MCP:** Always use `owner="your-org" repo="your-repo"`
```

The installer reads `Owner` and `Repo` to replace `{{GITHUB_OWNER}}` and `{{GITHUB_REPO}}` in all agents, commands, and skills.

## Stack Detection (automatic)

The installer auto-detects your stack and sets quality gate commands. If detection is wrong, add this section to override:

```markdown
### Quality Gates

- **Lint:** composer lint
- **Test:** composer test
```

Supported auto-detection:
- **Laravel / Laravel Zero** → `composer lint` + `composer test`
- **WordPress** → `composer lint` + `composer test`
- **React** → `npm run lint` + `npm test`
- **Vue** → `npm run lint` + `npm test`
- **Node** → `npm run lint` + `npm test`
- **Python** → `ruff check .` + `pytest`
- **Generic** → prompts you to configure manually

## Full Example

```markdown
# My Project

## Overview
Brief description of your project.

## Tech Stack
- **Language:** PHP 8.4
- **Framework:** Laravel Zero 12.x
- **Testing:** Pest
- **Linting:** Laravel Pint

### GitHub Repository

- **Owner:** myorg
- **Repo:** myproject
- **Full:** myorg/myproject
- **gh CLI:** Always use `--repo myorg/myproject`
- **GitHub MCP:** Always use `owner="myorg" repo="myproject"`

## Development Commands

```bash
composer test       # All checks: rector + pint + phpstan + pest
composer lint       # Fix formatting (Pint)
composer refactor   # Fix code (Rector)
```

## Code Conventions
- strict_types=1 in every file
- Final classes preferred
- Constructor injection only
- PSR-12 formatting

## Project-Specific Notes
<!-- Add env setup, key directories, deployment info, gotchas here -->
```
