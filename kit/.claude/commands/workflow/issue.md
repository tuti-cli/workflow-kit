# workflow:issue

> Execute a GitHub issue through the complete workflow pipeline.

**Usage:**
- `/workflow:issue <N>` — Full pipeline
- `/workflow:issue <N> --dry-run` — Show plan without executing
- `/workflow:issue <N> --worktree` — Full pipeline in isolated worktree
- `/workflow:issue <N> --quick` — Skip review stage, minimal checks

**Pipeline Stages:**
1. SETUP — Create branch, label in-progress
2. IMPLEMENT — Primary agent implements with squad
3. REVIEW + QUALITY — Parallel: code review + lint/test
4. COMMIT — Interactive diff review, conventional commit
5. PR — Push, draft PR → ready, label review
6. CLOSE — Summary comment, artifact cleanup

**Agent Squad:** Auto-selected from issue `type:*` label and keywords.

| Type Label | Primary | Secondary |
|------------|---------|-----------|
| `type: feature` | cli-developer | php-pro, laravel-specialist |
| `type: bug` | error-detective | code-reviewer, qa-expert |
| `type: chore` | refactoring-specialist | code-reviewer |
| `type: security` | security-auditor | code-reviewer |
| `type: performance` | performance-engineer | refactoring-specialist |
| `type: infra` | devops-engineer | deployment-engineer |
| `type: docs` | documentation-engineer | - |
| `type: test` | qa-expert | - |

Invoke `issue-executor` then `master-orchestrator`:
> "GITHUB REPO: owner={{GITHUB_OWNER}} repo={{GITHUB_REPO}}. Execute issue #$ARGUMENTS. Check for --dry-run, --worktree, --quick flags. IF --dry-run: read issue, validate, form squad, present plan WITHOUT executing. ELSE: invoke issue-executor to fetch, validate, enrich context from .workflow/patches/ and .workflow/ADRs/, then hand off to master-orchestrator for full pipeline execution. IF --worktree: create isolated worktree at .claude/worktrees/<N>-slug/. IF --quick: skip review stage, run minimal quality checks. After successful PR merge, invoke issue-closer."
