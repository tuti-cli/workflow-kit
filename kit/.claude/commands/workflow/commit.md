# workflow:commit

> Create a conventional commit with quality gate enforcement.

**Usage:**
- `/workflow:commit` — Interactive commit with diff review
- `/workflow:commit "message"` — Commit with specified message
- `/workflow:commit --pr` — Commit and create PR

**Commit Format:**
```
<type>(<scope>): <subject> (#N)
```
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Quality Gates (run before commit):**
```bash
{{QUALITY_GATE_LINT}}
{{QUALITY_GATE_TEST}}
```

Invoke `master-orchestrator`:
> "GITHUB REPO: owner={{GITHUB_OWNER}} repo={{GITHUB_REPO}}. Create a conventional commit. First run quality gates: `{{QUALITY_GATE_LINT}}` then `{{QUALITY_GATE_TEST}}`. Both must pass. Then review staged changes with `git diff --staged`. Generate conventional commit message with type(scope): subject, include issue reference if available. AskUserQuestion: 'Approve commit message?' → Yes / Edit / Cancel. IF --pr: after commit, push to origin and create draft PR via `gh pr create --draft --repo {{GITHUB_OWNER}}/{{GITHUB_REPO}}`."
