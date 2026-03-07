# CLAUDE.md Example

This is an example of the GitHub Repository section that workflow-kit needs in your project's CLAUDE.md file.

## Required Section

Add this to your project's `CLAUDE.md`:

```markdown
### GitHub Repository

- **Owner:** your-org
- **Repo:** your-repo
- **Full:** your-org/your-repo
- **gh CLI:** Always use `--repo your-org/your-repo`
- **GitHub MCP:** Always use `owner="your-org" repo="your-repo"`
```

## Full Example

```markdown
# My Project

## Overview
Brief description of your project.

## Tech Stack
- Language: PHP 8.4 / TypeScript / Python / etc.
- Framework: Laravel / Next.js / Django / etc.
- Testing: Pest / Jest / pytest / etc.

### GitHub Repository

- **Owner:** myorg
- **Repo:** myproject
- **Full:** myorg/myproject
- **gh CLI:** Always use `--repo myorg/myproject`
- **GitHub MCP:** Always use `owner="myorg" repo="myproject"`

## Development Commands

### Testing
```bash
composer test          # Run all tests
composer test:unit     # Unit tests only
composer lint          # Fix code style
```

### Building
```bash
npm run build          # Production build
npm run dev            # Development server
```

## Code Conventions
- Use strict types
- Final classes preferred
- Constructor injection only
- PSR-12 formatting
```

## How It Works

When you run `/workflow:init`:

1. workflow-kit reads your `CLAUDE.md`
2. Extracts the `Owner` and `Repo` values from the GitHub Repository section
3. Replaces `{{GITHUB_OWNER}}` and `{{GITHUB_REPO}}` template variables in agents
4. Agents are configured for your specific repository

## Multiple Repositories

If you work with multiple repositories, each project should have its own `CLAUDE.md` with the correct GitHub configuration. workflow-kit is installed per-project.
