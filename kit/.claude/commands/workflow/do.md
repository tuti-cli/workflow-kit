# workflow:do

> Execute a planned feature or GitHub issue. The main execution command.

**Usage:**
- `/ww:do` — execute scratch mode (from PLAN.md)
- `/ww:do N` — execute issues mode (from GitHub issue #N)
- `/ww:do --dry-run` — show plan without executing
- `/ww:do --worktree` — run in isolated git worktree
- `/ww:do --quick` — skip review stage

**Scratch mode (no issue number):**
1. Read .workflow/PLAN.md
2. Execute tasks from plan
3. Run quality gates
4. Commit to current branch

**Issues mode (with issue number):**
1. Invoke `issue-executor` to validate and enrich
2. Invoke `master-orchestrator` for full pipeline:
   - SETUP: branch, labels
   - IMPLEMENT: execute tasks
   - REVIEW + QUALITY: parallel gates
   - COMMIT: conventional commit
   - PR: create pull request
   - CLOSE: delegate to `issue-closer`

**Related:**
- `/ww:plan` — create plan first
- `/ww:commit` — just commit without full pipeline

Invoke `master-orchestrator`:
> "Run /ww:do. Read CLAUDE.md for workflow_mode. IF no issue number (scratch mode): read .workflow/PLAN.md, execute tasks, run quality gates, commit. IF issue number N (issues mode): invoke issue-executor first, then invoke master-orchestrator for full pipeline."
