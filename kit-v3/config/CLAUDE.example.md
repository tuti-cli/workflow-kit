# {{PROJECT_NAME}}

## Repository
- owner: {{GITHUB_OWNER}}
- repo: {{GITHUB_REPO}}

## Stack
- framework: {{STACK}}
- language: {{LANGUAGE}}
- test: {{QUALITY_GATE_TEST}}
- lint: {{QUALITY_GATE_LINT}}

## Workflow
- mode: scratch
- version: {{WK_VERSION}}

## Non-Negotiable Rules

### Quality
- Run `{{QUALITY_GATE_LINT}}` before every commit
- Run `{{QUALITY_GATE_TEST}}` before every commit
- Never commit failing tests
- Never ship without tests for new code

### Git
- Conventional commits: `<type>(<scope>): <description>`
- Never commit directly to main
- Never force push without explicit approval
- Never commit secrets or credentials

### Workflow
- Plan before code — present plan, wait for approval
- Never create agents for pipeline steps
- Skills = instincts, Agents = workers, Pipelines = steps
- "Does this need to think?" — validation rule for all new components

### Security
- Array syntax for shell execution — never string interpolation
- Use `.env` for config, ensure in `.gitignore`

## Context
- Stack details: .workflow/core/STACK.md
- Product description: .workflow/core/PROJECT.md
- Current plan: .workflow/core/PLAN.md
- Tech debt: .workflow/analysis/TECH-DEBT.md
