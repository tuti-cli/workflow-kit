# workflow:plan

> Plan a feature with task breakdown. Works in all three workflow modes.

**Usage:**
- `/ww:plan` — plan from description
- `/ww:plan --plan-only` — create plan, do not execute
- `/ww:plan --issue N` — plan from existing GitHub issue
- `/ww:plan --estimate` — include AI-assisted time estimates

**What it does:**
1. Reads CLAUDE.md + loads rules
2. Asks what you want to build (or reads from issue)
3. Creates structured task breakdown
4. Shows plan for approval
5. If approved → writes `.workflow/PLAN.md`

**Related:**
- `/ww:do` — execute after planning
- `/ww:create-issue` — turn PLAN.md into GitHub issue

Invoke `feature-planner`:
> "Run /ww:plan. Read CLAUDE.md for workflow_mode, stack, quality config. IF --issue N: fetch issue #N from GitHub. ELSE: ask user what they want to build. Invoke feature-planner to create task breakdown. Present plan for approval. IF approved: write .workflow/PLAN.md. IF --plan-only: stop here."
