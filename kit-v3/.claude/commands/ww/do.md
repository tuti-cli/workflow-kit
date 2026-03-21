# ww:do

> Execute a plan. Scratch mode from PLAN.md, issues mode from GitHub issue.

**Usage:**
- `/ww:do` — execute from PLAN.md (scratch mode)
- `/ww:do 42` — execute from GitHub issue #42 (issues mode)
- `/ww:do --dry-run` — show what would happen without executing
- `/ww:do --worktree` — run in isolated git worktree
- `/ww:do --quick` — skip review stage, minimal quality checks

## Scratch Mode (no issue number)

1. **Load plan**
   - Read `.workflow/core/PLAN.md`
   - If no PLAN.md: tell user to run `/ww:plan` first

2. **Present plan for approval**
   - Show task list
   - If `--dry-run`: stop here
   ```
   Ready to execute N tasks. Proceed?
   → Start | Edit plan | Cancel
   ```

3. **Implement tasks**
   - Execute tasks from PLAN.md in order
   - Respect dependencies
   - Mark tasks complete as they finish

4. **Quality gates**
   - Run lint command from CLAUDE.md
   - Run test command from CLAUDE.md
   - If fail: auto-fix retry (1x), then stop and report

5. **Done**
   - Show summary of what was implemented
   - Suggest: `/ww:commit` to commit changes

## Issues Mode (with issue number)

1. **Fetch and validate issue**
   - `gh issue view N --repo {owner}/{repo} --json title,body,labels,state`
   - Check required labels exist (type, priority, status)
   - Check required body sections (Summary, Context, Acceptance Criteria)
   - If validation fails: report what's missing, stop

2. **Auto-label if needed**
   - Detect type from content keywords
   - Suggest labels, wait for confirmation
   - Apply via `gh issue edit N --add-label`

3. **Setup**
   - Check current branch, ask where to branch from
   - Create branch: `{type}/{N}-{slug}`
   - Update issue label: add `status:in-progress`, remove `status:ready`
   - Post "Workflow started" comment on issue

4. **Present plan for approval**
   - Generate implementation plan from issue
   - If `--dry-run`: stop here
   ```
   Implementation plan for #N. Proceed?
   → Start | Edit plan | Cancel
   ```

5. **Implement**
   - Execute plan
   - Commit checkpoint every 3-5 tasks

6. **Quality gates**
   - Run lint + test
   - If `--quick`: run lint only
   - If fail: auto-fix retry, then stop

7. **Review** (skip if `--quick`)
   - Self-review the complete diff
   - Show summary of all changes

8. **Done**
   - Show summary
   - Suggest: `/ww:commit --pr` to commit and create PR

## Worktree Mode (--worktree)

- Create isolated worktree: `git worktree add .worktrees/{N}-{slug}`
- Run all steps inside worktree
- On completion: inform user of worktree path
