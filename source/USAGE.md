# tuti-kit Usage Manual

> How to use the workflow system in each situation to get accurate, expected results.
> Keep this open when working — reference it when something feels off.

---

## Table of Contents

1. [Before You Start — The Mental Model](#1-before-you-start--the-mental-model)
2. [Setting Up a Project](#2-setting-up-a-project)
3. [Scratch Mode — Fast Feature Shipping](#3-scratch-mode--fast-feature-shipping)
4. [Issues Mode — GitHub Workflow](#4-issues-mode--github-workflow)
5. [Legacy Mode — Onboarding Existing Projects](#5-legacy-mode--onboarding-existing-projects)
6. [The Rules System — Teaching Claude Your Conventions](#6-the-rules-system--teaching-claude-your-conventions)
7. [Architecture Decisions](#7-architecture-decisions)
8. [When Claude Does Something Wrong](#8-when-claude-does-something-wrong)
9. [Estimating Work](#9-estimating-work)
10. [Working with Agents](#10-working-with-agents)
11. [Troubleshooting](#11-troubleshooting)
12. [Quick Reference Card](#12-quick-reference-card)

---

## 1. Before You Start — The Mental Model

### How the system works

tuti-kit is a set of Claude Code agents, commands, and rules files that work together as a structured workflow. Think of it as giving Claude a playbook it reads at the start of every session:

```
Session starts
    ↓
Claude reads CLAUDE.md          ← your config, stack, mode
    ↓
Claude loads rules layers       ← base → project → features
    ↓
Claude reads active-rules.md   ← merged view of all rules
    ↓
You give a command
    ↓
Claude executes with correct context
```

### The three things that matter most

**1. CLAUDE.md is the only config file.**
Every agent reads it first. Owner/repo, stack, test commands — all in one place. If you change something about your project setup, change it here.

**2. Rules files are how you teach Claude your conventions.**
If Claude writes `array_key_exists()` instead of `Arr::has()`, that is a missing rule, not a bug. Add the rule once, and Claude follows it forever.

**3. Modes control pipeline complexity.**
Scratch mode is fast — no issues, no PRs required. Issues mode is full process. Switch when your project needs it, not before.

---

## 2. Setting Up a Project

### New project from scratch

```bash
# In the project directory, with Claude Code open:
/workflow:init
```

Claude will ask:
- Which stack? (laravel / vue / react / wordpress / next / nuxt)
- Any extras? (inertia / livewire / filament / tailwind / alpine)
- GitHub owner (org or username)
- Repository name

After init, immediately add your conventions:

```bash
/rules:add project "Always use Arr:: helpers not native PHP array functions"
/rules:add project "Enum names must be suffixed with Enum — PaymentStatusEnum not PaymentStatus"
/rules:add project "Prefer Inertia for form submissions — never use axios for page-level forms"
```

Then verify Claude sees them:
```bash
/rules:show project
```

### Onboarding an existing project

```bash
/workflow:discover
# or point at a specific directory:
/workflow:discover ./my-project
```

Claude will:
1. Scan the codebase and detect stack, test runner, provider
2. Ask you to confirm what it found
3. Write CLAUDE.md, create rules starters, install agents
4. Run a full audit → AUDIT.md + TECH-DEBT.md
5. Ask if you want GitHub issues created from tech debt

**After discover:**
1. Review `.workflow/AUDIT.md` — understand the health of the codebase
2. Review `.workflow/TECH-DEBT.md` — prioritise what to fix
3. Add your conventions: `/rules:add project "..."`
4. Scan existing code patterns and add them as rules

### Graduating from Scratch to Issues mode

When your project has grown and you want a proper issue-driven workflow:

```bash
/workflow:mode set issues
```

Claude will verify: GitHub credentials are set, owner/repo are configured, provider file exists. If anything is missing, it tells you exactly what to fix.

---

## 3. Scratch Mode — Fast Feature Shipping

**When to use:** New project, solo work, rapid iteration, POC, you don't need a GitHub issue trail.

**The loop:**

```
/workflow:plan   →  approve plan  →  /workflow:build  →  done
```

### Step 1: Plan a feature

```bash
/workflow:plan
```

Describe what you want to build. Claude will:
- Create a task breakdown with time estimates
- Show you each task with `~X min` estimates
- Show total: generation + test cycles + manual review
- Ask for approval before touching any code

**What good plan output looks like:**
```
📋 Plan ready: User Authentication

Tasks: 6 across 3 phases
Estimate: ~1h 45min (generation: ~55min, fix cycles: ~20min, review: ~10min, buffer: ~10min)

Phase 1: Setup (~25 min)
  1.1 Create AuthController skeleton    ~10 min
  1.2 Add sanctum to composer           ~5 min
  1.3 Publish sanctum config            ~10 min

Phase 2: Implementation (~55 min)
  2.1 Implement login endpoint          ~20 min
  2.2 Implement logout endpoint         ~15 min
  2.3 Add token refresh                 ~20 min

Phase 3: Tests (~25 min)
  3.1 Feature tests for all endpoints   ~25 min

Proceed? → Approve | Edit | Cancel
```

Approve it, then:

### Step 2: Execute the plan

```bash
/workflow:build
```

Claude executes tasks in order, runs quality gates at each checkpoint, and asks before committing. You can watch it work or go make coffee.

**If Claude asks you something mid-build:** It found something ambiguous or hit an overrun. Answer it — don't let it guess.

### Step 3: Commit

After build completes:
```bash
/workflow:commit
```

Or build already asks you about it and creates the commit automatically.

### Plan-only mode (just planning, no execution)

```bash
/workflow:plan
# When Claude asks to proceed → choose "Cancel" or use --plan-only flag
/workflow:feature --plan-only
```

Use this when you want to review the plan, estimate the work, or push it to a GitHub issue:
```bash
/workflow:create-issue  # creates issue from PLAN.md, ready for Issues mode later
```

---

## 4. Issues Mode — GitHub Workflow

**When to use:** Growing project, working with a team, need audit trail, want proper PRs.

### Setup requirements

```bash
# Verify you're in issues mode
/workflow:mode

# If not:
/workflow:mode set issues

# Verify GitHub auth
gh auth status
```

### The full loop

```
Create issue  →  /workflow:issue <N>  →  PR merged  →  issue auto-closed
```

### Creating issues

**From a plan:**
```bash
/workflow:plan               # plan the feature
/workflow:create-issue       # turn PLAN.md into a GitHub issue
```

**From an ADR decision:**
```bash
/arch:decide                 # creates ADR + automatically creates implementation issue
```

**From audit findings:**
```bash
/workflow:audit              # produces TECH-DEBT.md
# Answer yes when asked "Create issues from tech debt?"
```

**Issues must have:**
- One `workflow:` label (workflow:feature, workflow:bugfix, etc.)
- One `priority:` label
- Status `status:ready`
- Body sections: Summary, Context, Acceptance Criteria, Definition of Done

### Executing an issue

```bash
/workflow:issue 42
```

**What happens:**
1. Fetches issue #42 from GitHub
2. Validates it has all required sections and labels (auto-labels if missing, asks you to confirm)
3. Loads rules layers + relevant patches + ADRs
4. Forms the right agent squad based on your stack + issue keywords
5. Creates branch `feature/42-slug` from main
6. Presents implementation plan with estimates — you approve
7. Implements, runs REVIEW + QUALITY in parallel
8. Creates commit, creates PR
9. After PR merge → posts summary comment, closes issue, archives PLAN.md

### Quick mode (skip code review stage)

```bash
/workflow:issue 42 --quick
```

Skips the REVIEW stage (code-reviewer agent). Use for small, low-risk tasks. Quality gates still run.

### Isolated worktree (parallel work)

```bash
/workflow:issue 42 --worktree
```

Creates an isolated git worktree so you can work on multiple issues simultaneously without branch conflicts.

### Bug fixes

```bash
/workflow:bugfix 87
```

Same as issue but optimised for bugs: adds regression test requirement, writes a patch file to `.workflow/patches/` for future learning.

---

## 5. Legacy Mode — Onboarding Existing Projects

**When to use:** Taking over a legacy codebase, pre-existing project without tuti-kit, migration needed.

### Full discovery flow

```bash
/workflow:discover
```

This is the most thorough setup. Takes 10-20 minutes for a medium codebase but gives you:
- Full audit of codebase health
- Tech debt registry
- Stack configuration
- Agent setup
- (Optional) GitHub issues for all debt items

### After discovery

Review the outputs:
```bash
# Audit findings — what's in the codebase
cat .workflow/AUDIT.md

# Prioritised debt — what to fix
cat .workflow/TECH-DEBT.md

# See active rules
/rules:show
```

Then add your conventions based on what you found in the code:
```bash
/rules:add project "This codebase uses Repository pattern — all DB queries must go through repositories"
/rules:add project "Legacy controllers can be fat — do not refactor in features, only in dedicated refactor issues"
```

### Planning a migration phase

```bash
/workflow:plan
# Describe: "Migrate the UserController to use UserService — phase 1 of auth refactor"
```

Claude will create a migration plan respecting legacy constraints, with phase isolation so you can roll back.

### Running a migration phase

```bash
/workflow:build   # scratch mode
# or
/workflow:issue <N>  # issues mode, after switching mode
```

Each phase is a separate branch + PR. Never migrate multiple modules in one PR — if it breaks, rollback is impossible.

---

## 6. The Rules System — Teaching Claude Your Conventions

This is the most important section. The rules system is how you eliminate "Claude did it wrong again" from your workflow.

### The three layers

```
features/auth.md        ← highest priority — subsystem rules
features/payments.md
    ↑ override
project/conventions.md  ← project decisions
project/stack.md
    ↑ override
base/coding-standards.md  ← global style
base/testing.md
base/git.md
base/architecture.md
```

Later layers override earlier ones. **Feature rules always win.**

### Adding a rule immediately when you spot a problem

You're mid-session. Claude writes something wrong. **Do this:**

```bash
/rules:add project "Always use Arr::get() not $array['key'] ?? null"
```

Claude fixes the current code AND saves the rule permanently. It will never make that mistake again.

### Checking what rules Claude has

```bash
/rules:show           # show everything
/rules:show project   # show project layer only
/rules:show features  # show all feature rules
```

### When to use each layer

**Use `base/` for:** conventions you apply to every project you work on — commit format, class naming, test structure, architecture patterns.

**Use `project/` for:** decisions specific to this project — which packages to prefer, naming conventions you chose, architectural decisions.

**Use `features/` for:** rules that only apply to one subsystem — auth-specific rules, payment-specific rules, anything that should override the general approach.

### Syncing after edits

Always sync after editing any rules file manually:
```bash
/workflow:sync
```

The commands `/rules:add` and `/rules:edit` do this automatically. Manual edits do not.

### Practical examples

**You always use Carbon::parse() not new Carbon():**
```bash
/rules:add project "Always use Carbon::parse() not new Carbon() — consistent timezone handling"
```

**Auth endpoints must always use a specific middleware:**
```bash
/rules:add features/auth "All auth endpoints must use ['auth:sanctum', 'verified'] middleware — never auth alone"
```

**Your project uses a specific response format:**
```bash
/rules:add project "API responses must use ApiResource — never raw array returns from controllers"
```

**After an ADR is written (auto-happens via /arch:decide):**
```bash
# arch:decide automatically updates rules/project/architecture.md
# But you can also add manually:
/rules:add project "Use event-driven communication between domains — never direct service imports across domain boundaries"
```

---

## 7. Architecture Decisions

When you face a significant architectural decision, use the arch flow instead of just picking an approach and hoping Claude follows it.

### The flow

```bash
/arch:brainstorm     # 2-3 options with tradeoffs
/arch:challenge      # devil's advocate — finds problems with the proposal
/arch:decide         # locks in the decision, writes ADR, updates rules
```

### Why this matters

`/arch:decide` does three things:
1. Writes a permanent ADR to `.workflow/ADRs/`
2. Updates `.claude/rules/project/architecture.md` with the decision
3. Runs `/workflow:sync` so Claude sees it immediately

The ADR is your "why we did it this way" record. The rules update is what makes Claude respect the decision in every future session.

### Example

```bash
/arch:brainstorm
# "We need to decide how to handle multi-tenancy — separate databases vs shared DB with tenant_id"

/arch:challenge
# Claude plays devil's advocate on the proposal

/arch:decide
# Locks in: "shared DB with tenant_id, enforced via global scope on all models"
# → ADR written
# → rules/project/architecture.md updated: "All queries must go through TenantScope"
# → /workflow:sync runs
```

From now on, every agent knows about TenantScope and will add it to new models automatically.

---

## 8. When Claude Does Something Wrong

### Claude wrote code that violates your conventions

```bash
# 1. Tell Claude to fix the current code
"Fix this — use Arr::has() not array_key_exists()"

# 2. Permanently add the rule
/rules:add project "Always use Arr::has() not array_key_exists()"

# 3. Verify it's saved
/rules:show project
```

### Claude forgot a rule from a previous session

Sessions don't share memory. Rules files are the memory.

```bash
# 1. Check if the rule exists
/rules:show

# 2. If missing — add it
/rules:add project "The missing rule"

# 3. If it's there but Claude ignored it — re-sync
/workflow:sync
# Then start fresh in a new context window
```

### The plan had wrong estimates (too high or too low)

Estimates are averages. Some tasks genuinely take longer due to:
- Ambiguous requirements → clarify them upfront with more detail in the plan
- Novel patterns not in the codebase → add existing patterns to rules
- Complex interdependencies → split the task further

If you notice a pattern of wrong estimates for a task type:
```bash
/rules:add project "Note for estimates: our domain event setup always takes 40-50 min due to many event listeners — plan accordingly"
```

### Claude used the wrong agent/specialist

This means stack detection got it wrong, or the issue keywords didn't trigger the right agent. Fix it:
1. Verify `CLAUDE.md` has the right `stack` value
2. If keywords are the issue, add explicit agent mention to the issue body

### Quality gates keep failing

```bash
/workflow:gate    # run full gate, see exactly what's failing
```

Common causes:
- Missing tests → Claude needs to write them first
- Coverage drop → new code didn't get tests
- Lint errors → run auto-fix: `composer lint` or `npm run lint`
- Type errors → these need human analysis, Claude can't auto-fix reliably

---

## 9. Estimating Work

### How to read AI-assisted estimates

The estimate breakdown is always shown before execution:

```
Code generation:  ~55 min    ← fast, predictable
Test fix cycles:  ~20 min    ← 1-2 cycles expected
Manual review:    ~10 min    ← your eyes on the output
Buffer (10%):     ~10 min
Total:            ~1h 35min
```

**The manual review time is real.** Don't skip it. Claude's output needs your verification.

**Test fix cycles are expected.** 1-2 cycles of "test fails → Claude fixes → test passes" is normal.

### When a task overruns

If Claude surfaces an overrun warning:
```
⚠️ Estimate overrun: "PaymentService.charge()" estimated ~25 min, now at ~40 min
Reason: 3 test fix cycles — unexpected edge case in idempotency handling
Options: Continue (+~15 min) | Pause and clarify | Split task
```

**Pause and clarify** is almost always the right choice. Add the clarification as a rule:
```bash
/rules:add features/payments "Idempotency key must be generated as UUID v4 by the caller — not by the service"
```

Then continue. The next similar task will be estimated correctly.

### What AI estimates don't account for

- **Your review finding real bugs** — the "manual review" budget assumes you're verifying, not debugging
- **Requirement changes mid-task** — if you change what you want, add time
- **Environment issues** — Docker not running, missing credentials, etc.
- **Novel unsolved problems** — if no similar pattern exists in the codebase

---

## 10. Working with Agents

### Installing a new agent

```bash
/agents:search php        # find agents by keyword
/agents:install php-pro   # install with full adaptation pass
```

Every installed agent is automatically adapted:
- Redundant sections stripped (reduces context bloat ~50%)
- Project context pointer injected
- Stack-specific quality commands injected

**Stack specialist agents are not pre-bundled in tuti-kit.** They are installed
automatically during `/workflow:init` or `/workflow:discover` once your stack is
detected. This means each project only has the agents it actually needs — a Laravel
project never gets `vue-specialist`, a React project never gets `laravel-specialist`.

If you skipped init/discover and need a specialist manually:
```bash
/agents:install laravel-specialist
/agents:install vue-specialist
/agents:install react-specialist
/agents:install wp-specialist
```

### Updating an agent after stack changes

```bash
/agents:install php-pro --update
```

Re-runs the adaptation pass with current CLAUDE.md values.

### Viewing installed agents

```bash
/agents:list          # all installed
/agents:list --local  # this project only
/agents:list --global # globally installed
```

### When an agent behaves unexpectedly

1. Check if it still has the context pointer: read the agent's .md file
2. If missing: reinstall with `--update`
3. If context pointer is there: check if the relevant rules exist with `/rules:show`

### Protected agents

These cannot be removed without `--force`:
- master-orchestrator, issue-executor, issue-creator, issue-closer
- agent-installer, workflow-orchestrator, project-analyst
- feature-planner, task-decomposer

They are the core of the system. Remove them only if you're intentionally rebuilding.

---

## 11. Troubleshooting

### "I ran /workflow:issue but Claude is using the wrong repo"

```bash
cat CLAUDE.md | grep repo_owner
# If wrong: edit CLAUDE.md and fix repo_owner and repo_name
```

### "Claude keeps drifting from my coding style"

```bash
/rules:show          # check what rules exist
/workflow:sync       # rebuild active-rules.md
/rules:add project "The specific rule Claude is forgetting"
```

### "PLAN.md is empty / plan was lost"

Plans are archived to `.workflow/features/` after completion. Check there:
```bash
ls .workflow/features/
```

### "Tests are failing and I don't know why"

```bash
/workflow:gate       # full diagnostic — shows exactly what's failing
/workflow:test       # run tests with detailed output
```

### "I want to see what rules Claude is using right now"

```bash
/rules:show          # shows active-rules.md
```

If it's stale or missing:
```bash
/workflow:sync       # rebuilds it
/rules:show          # now current
```

### "The agent installed from catalog is misbehaving"

```bash
/agents:install [name] --update   # re-run adaptation pass
```

### "I'm switching from GitHub to GitLab"

1. Edit `.claude/providers/PROVIDER.md` (copy from `gitlab.md` when it exists)
2. Update `provider: gitlab` in `CLAUDE.md`
3. Update `repo_owner` and `repo_name` if they changed

---

## 12. Quick Reference Card

### Daily commands

| Situation | Command |
|-----------|---------|
| Plan a feature | `/workflow:plan` |
| Execute current plan | `/workflow:build` |
| Execute a GitHub issue | `/workflow:issue <N>` |
| Fix a bug | `/workflow:bugfix <N>` |
| Commit current changes | `/workflow:commit` |
| Run quality checks | `/workflow:gate` |
| Run tests | `/workflow:test` |

### Rules — adding and checking

| Situation | Command |
|-----------|---------|
| Add a rule right now | `/rules:add project "..."` |
| Add a feature-specific rule | `/rules:add features/auth "..."` |
| See all active rules | `/rules:show` |
| Edit a rules file | `/rules:edit project/conventions` |
| Rebuild rules snapshot | `/workflow:sync` |

### Project setup

| Situation | Command |
|-----------|---------|
| New project | `/workflow:init` |
| Existing project | `/workflow:discover` |
| Check current mode | `/workflow:mode` |
| Switch to Issues mode | `/workflow:mode set issues` |
| Switch back to Scratch | `/workflow:mode set scratch` |

### Architecture

| Situation | Command |
|-----------|---------|
| Explore options | `/arch:brainstorm` |
| Challenge a proposal | `/arch:challenge` |
| Lock in decision + ADR | `/arch:decide` |

### Agents

| Situation | Command |
|-----------|---------|
| Find an agent | `/agents:search <query>` |
| Install an agent | `/agents:install <name>` |
| See installed agents | `/agents:list` |
| Update an agent | `/agents:install <name> --update` |

### When things go wrong

| Problem | Fix |
|---------|-----|
| Claude used wrong convention | `/rules:add project "..."` + fix current code |
| Rules seem stale | `/workflow:sync` |
| Wrong repo in commands | Edit `CLAUDE.md` → `repo_owner` + `repo_name` |
| Overrun warning appeared | Pause, clarify, add rule, continue |
| Tests failing | `/workflow:gate` to diagnose |

---

*tuti-kit Usage Manual · Keep this file updated as you discover new patterns.*
*Add your own tips to section 11 when you solve a new problem.*
