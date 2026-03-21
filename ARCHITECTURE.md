# Architecture Decisions

This document captures every architectural decision made for workflow-kit v3 and the reasoning behind each one.

## Three-Layer Model

The system uses exactly three layers. Every component must fit into one of them. No exceptions.

### Skills (Instincts)

Skills shape how Claude thinks during a session. They are loaded into context and influence every line of code written. They never "run" or "execute" — they modify behavior.

**Example:** `laravel-specialist` — when loaded, Claude follows Laravel conventions for every file it touches. It doesn't do a specific job. It changes how all jobs are done.

**Properties:**
- Never called directly (background knowledge)
- Always on or loaded by agent declaration in frontmatter
- Written as "how to think" not "what to do"
- Cost: tokens in context, but only when loaded

**Location:** `.claude/skills/`

### Agents (Workers)

Agents are spawned as subagents via Claude Code's native `Agent` tool. Each agent gets a specific job, does it in its own context window, reports results back, and dies.

**Example:** `security-auditor` — spawned with "scan these files for vulnerabilities." It reads code, finds issues, returns a structured report. Then it's gone.

**Properties:**
- Spawned intentionally for a specific task
- Own context window (isolated from main session)
- Clear input/output contract (what goes in, what comes back)
- Declare required skills in frontmatter
- Cost: separate Claude session per agent

**Location:** `.claude/agents/`

### Pipelines (Command Logic)

Pipelines are deterministic steps inside commands. They have no autonomy and no decision-making. They sequence actions in a defined order.

**Example:** The `/ww:commit` pipeline: run lint, run tests, show diff, ask for approval, create commit. Every step is predetermined.

**Properties:**
- No intelligence — just ordered procedure
- Live inside command `.md` files
- Not reusable as independent reasoning units

**Location:** `.claude/commands/ww/`

### The Validation Rule

When creating any new component, ask: **"Does this need to think?"**

| Answer | Layer | Example |
|--------|-------|---------|
| No | Pipeline step | Fetch issue, create branch, run lint |
| Yes, always the same way | Skill | Laravel conventions, clean code patterns |
| Yes, depends on context/goal | Agent | Security audit, code review, bug diagnosis |

### Anti-Patterns We Explicitly Reject

- **Agent that is a pipeline step.** `issue-executor` doesn't need to think — it fetches and validates. That's a pipeline step inside `/ww:do`.
- **Skill that does a job.** A skill should never "scan for vulnerabilities." That's an agent's job.
- **"Master orchestrator" agent that just sequences steps.** Orchestration is pipeline logic. The only orchestrator that earns agent status is one that dynamically plans, adapts, and spawns subagents — and that's the `master-orchestrator` entry point.
- **Overlapping skill and agent.** Never have `refactoring-skill` and `refactoring-agent` that cover the same ground. The skill teaches patterns. The agent analyzes code for opportunities. Different jobs, no overlap.

## Two Entry Points

The same pipeline logic is accessible two ways:

### Commands (Manual)

The user types each step. Claude executes that step and waits.

```
/ww:plan     → user reviews plan
/ww:do       → user reviews implementation
/ww:commit   → user reviews diff and message
```

Best for: learning the system, debugging workflows, precise control.

### Orchestrator (Automated)

The user runs `claude --agent master-orchestrator`. The orchestrator drives the pipeline, spawning subagents for parallel work, and stops at defined checkpoints for human approval.

```
orchestrator → plans → checkpoint → implements → spawns reviewers → checkpoint → commits
```

Best for: end-to-end execution of known workflows.

Both entry points share the same pipeline logic. Commands are not simplified versions — they are the same steps, just human-paced.

## Subagents, Not Agent Teams

We use Claude Code's native subagent system exclusively.

| Property | Subagents (what we use) | Agent Teams (what we don't) |
|----------|------------------------|----------------------------|
| Context | Own window, results return to caller | Own window, fully independent |
| Communication | Report back to main agent only | Teammates message each other |
| Coordination | Main agent manages all work | Shared task list, self-coordination |
| Token cost | Lower — results summarized back | Higher — each is a separate instance |
| Complexity | Simple — spawn, get result, continue | Complex — coordination overhead |

Subagents are the right choice because our agents do focused, independent jobs. A security auditor doesn't need to discuss findings with a code reviewer. It scans, reports, and dies. The orchestrator synthesizes results from multiple agents.

## Rules vs Skills Separation

We keep `rules/` and `skills/` as separate directories because they have fundamentally different loading guarantees.

| Property | Rules | Skills |
|----------|-------|--------|
| Loading | Always loaded automatically | Loaded by description match or agent declaration |
| Purpose | "Never do X, always do Y" | "When working with Z, here's how" |
| Failure mode | If forgotten: something breaks | If forgotten: code is uglier but works |

**Hard rules** live in CLAUDE.md — they are loaded every session without exception. These are the rules where forgetting them causes real damage: broken commits, failed tests, security issues.

**Soft rules** live in `rules/` — they auto-load from the directory. These are coding standards, testing patterns, git conventions. Important but not catastrophic if temporarily missed.

**Skills** live in `skills/` — they load conditionally. Stack-specific knowledge, workflow behavior, tool patterns. Only relevant for certain tasks.

### Rule Placement Validation

When adding a new rule via `/ww:rules-add`, the system validates placement:

1. "If Claude forgets this, does something break?" → Yes = hard rule in CLAUDE.md
2. If soft rule: which layer? Base (universal), project (this repo), features (subsystem)
3. Present suggestion with reasoning, wait for confirmation

## Self-Improvement Flow

The system learns from failures but never mutates itself without human approval.

```
Step 1: Pipeline fails (test, lint, unexpected error)
Step 2: Auto-fix retry (1-2 attempts depending on error type)
Step 3: If still failing → spawn error-detective agent
Step 4: Agent analyzes failure, produces diagnosis and suggestions
Step 5: Present suggestions to user with reasoning
Step 6: User approves, rejects, or modifies
Step 7: Approved changes applied
```

No silent system mutation. Every change to skills, rules, or agents requires explicit human approval.

## File Structure Decisions

### `.claude/` — Claude Code Configuration

```
.claude/
  agents/           Real agents only. Each is a focused worker.
  commands/ww/      All 14 commands under unified namespace.
  rules/            Always-loaded behavioral rules.
    base/           Universal (git, testing, coding standards)
    project/        This project (stack, conventions, arch decisions)
    features/       Subsystem-specific (auth, payments)
  skills/           Conditionally-loaded knowledge.
    workflow/       System behavior (workflow-execution, grill-me)
    stack/          Stack-specific (laravel, vue, populated by discover)
    tools/          General patterns (clean-code)
```

### `.workflow/` — Workflow Artifacts

```
.workflow/
  core/             Living documents: STACK.md, PROJECT.md, PLAN.md
  analysis/         Point-in-time snapshots: AUDIT.md, TECH-DEBT.md
  decisions/ADRs/   Architecture Decision Records
  execution/        Runtime artifacts: patches/, features/
  meta/             Design artifacts: proposals/, challenges/
```

### Key File Naming

| File | Created by | Contains |
|------|-----------|----------|
| `STACK.md` | `/ww:discover` | Technical: framework, language, tools, quality gates |
| `PROJECT.md` | `/ww:describe` | Product: features, architecture, scope, constraints |
| `PLAN.md` | `/ww:plan` | Execution: task breakdown, priorities, dependencies |

These are deliberately named differently to avoid confusion. STACK describes the technology. PROJECT describes the product. PLAN describes what to build next.

## CLAUDE.md as Lean Config

CLAUDE.md is the most expensive file — always loaded, always consuming tokens. We keep it minimal:

- Repository config (owner, repo)
- Stack summary (framework, lint command, test command)
- Workflow mode and version
- Hard rules (non-negotiable, would break things if forgotten)
- Pointers to detailed files (STACK.md, PROJECT.md, PLAN.md)

Everything else lives in dedicated files that load on demand.

## Grill Process

The grill-me skill is embedded into `/ww:describe` and `/ww:plan` as the core validation mechanism.

- `/ww:describe` grills the WHAT — challenges requirements, finds contradictions, fills gaps
- `/ww:plan` grills the HOW — challenges feasibility, scope, ordering, test coverage

Both must pass interrogation before producing output. This prevents vague plans and unclear requirements from entering the pipeline.

## Per-Project Installation

Everything installs into the project repository. This means:
- Any team member who clones the repo gets the full workflow
- Project-specific skills and rules travel with the code
- No dependency on global configuration

Global installation (to `~/.claude/`) is deferred to a future optimization.

## Phase Plan

### Phase 1 (Current)
All commands run manually. No agents spawned. User drives every step. This validates the pipeline logic and skill quality before adding automation.

### Phase 2 (Future)
Wire in agents. Orchestrator drives the pipeline. Subagents handle parallel work (lint+test, code review, security audit). Human approves at checkpoints.
