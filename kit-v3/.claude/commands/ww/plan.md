# ww:plan

> Create a task breakdown with priorities. Grills the plan before finalizing.

**Usage:**
- `/ww:plan` — plan from description (interactive)
- `/ww:plan --issue N` — plan from existing GitHub issue
- `/ww:plan --plan-only` — create plan, do not execute
- `/ww:plan --estimate` — include time estimates per task

## Steps

1. **Load context**
   - Read CLAUDE.md for stack, mode, quality config
   - Read `.workflow/core/PROJECT.md` if exists
   - Read `.workflow/core/STACK.md` if exists

2. **Determine source**
   - If `--issue N`: fetch issue via `gh issue view N --json title,body,labels`
   - Else if PROJECT.md exists: use as input
   - Else: ask user what they want to build

3. **Create task breakdown**
   - Break into atomic, implementable tasks
   - Order by dependency (what blocks what)
   - Assign priority: critical / high / medium / low
   - If `--estimate`: add time estimates per task

4. **Grill the plan** (uses grill-me skill)

   **Feasibility check:**
   - "Task X depends on Y but Y isn't in the plan — what's missing?"
   - "This task is too vague to implement — what specifically gets built?"
   - "These 3 tasks could be one — why split them?"

   **Scope check:**
   - "Is this MVP or full feature?"
   - "What can be deferred without blocking the rest?"

   **Quality check:**
   - "Where are the tests in this plan?"
   - "Which tasks need database migrations?"

5. **Write PLAN.md**

   Write to `.workflow/core/PLAN.md`:

   ```markdown
   # Plan: [Title]

   Source: [PROJECT.md / Issue #N / user description]
   Created: [date]
   Mode: [scratch / issues]

   ## Tasks

   ### Phase 1: [name]
   - [ ] Task 1 — description [priority: high]
   - [ ] Task 2 — description [priority: high]

   ### Phase 2: [name]
   - [ ] Task 3 — description [priority: medium]
   - [ ] Task 4 — description [priority: medium]

   ## Dependencies
   - Task 3 requires Task 1
   - Task 4 requires Task 2

   ## Notes
   - ...
   ```

6. **Present for approval**
   ```
   PLAN.md created with N tasks. Review and approve?
   → Approve | Edit | Re-grill | Cancel
   ```
