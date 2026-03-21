# ww:status

> Show workflow-kit version, configuration, and project state.

**Usage:**
- `/ww:status` — full status dashboard

## Steps

1. **Read configuration**
   - CLAUDE.md: owner, repo, stack, mode, version
   - Quality gates: lint command, test command

2. **Count installed components**
   - Agents: count `.claude/agents/*.md`
   - Commands: count `.claude/commands/ww/*.md`
   - Skills: count `.claude/skills/**/*.md`
   - Rules: count `.claude/rules/**/*.md`

3. **Check workflow state**
   - PLAN.md exists? Show title and task progress
   - STACK.md exists? Show detected stack
   - PROJECT.md exists? Show project name
   - AUDIT.md exists? Show last audit date
   - TECH-DEBT.md exists? Show item count by priority
   - ADRs: count `.workflow/decisions/ADRs/*.md`
   - Patches: count `.workflow/execution/patches/*.md`

4. **Display dashboard**
   ```
   workflow-kit Status
   ===================

   Version:  v1.0.0
   Stack:    laravel
   Mode:     scratch
   GitHub:   org/repo

   Quality Gates:
     Lint:   composer lint
     Test:   composer test

   Components:
     Agents:   3
     Commands: 14
     Skills:   5
     Rules:    8

   Workflow:
     Plan:     feature-auth (4/7 tasks done)
     ADRs:     2
     Patches:  3
     Debt:     5 items (1 critical)
   ```
