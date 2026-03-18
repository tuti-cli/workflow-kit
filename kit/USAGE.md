# workflow-kit Usage Guide

> Real-world workflow cases for each command.

---

## Starting a New Project (Scratch Mode)

### Scenario: You're building an MVP from scratch

```bash
# 1. Initialize
/ww:init

# 2. Plan your feature
/ww:plan
# Describe: "Build user authentication with email/password"
# Gets task breakdown, estimates

# 3. Execute
/ww:do
# Runs: IMPLEMENT → QUALITY → COMMIT
# Commits to main (no branches in scratch mode)
```

**When to use scratch mode:**
- New project, no existing code
- Rapid prototyping
- Solo development
- Don't need issue tracking yet

---

## Working with GitHub Issues

### Scenario: You have a feature request in GitHub

```bash
# Plan from existing issue
/ww:plan --issue 42

# Execute the issue
/ww:do 42

# Pipeline: SETUP → IMPLEMENT → REVIEW → COMMIT → PR → CLOSE
```

**What happens:**
1. Creates branch `feature/42-short-slug`
2. Runs quality gates (lint + tests)
3. Creates PR
4. After merge: closes issue with summary

### Scenario: Quick bug fix

```bash
# Dry-run to see the plan first
/ww:do 15 --dry-run

# Execute with minimal checks
/ww:do 15 --quick
```

---

## Codebase Analysis

### Scenario: Inherit a legacy project

```bash
# Full audit
/ww:audit --legacy

# Creates:
# - .workflow/AUDIT.md (health snapshot)
# - .workflow/TECH-DEBT.md (prioritized debt)
```

### Scenario: Regular health check

```bash
/ww:audit
# Quick scan: dependencies, coverage, security
```

---

## Architecture Decisions

### Scenario: Choosing between two approaches

```bash
# 1. Brainstorm options
/ww:arch brainstorm multi-tenancy

# 2. Challenge proposal (get critique)
/ww:arch challenge multi-tenancy

# 3. Decide and document
/ww:arch decide multi-tenancy
```

**Creates:**
- `.workflow/proposals/multi-tenancy.md`
- `.workflow/challenges/multi-tenancy.md`
- `.workflow/ADRs/001-multi-tenancy.md`
- Updates `.claude/rules/project/architecture.md`

---

## Maintenance & Improvements

### Scenario: Regular improvement work

```bash
# Plan from issue
/ww:plan --issue 25

# Execute
/ww:do 25
```

### Scenario: Just need to commit current work

```bash
# Quality gates + commit (no full pipeline)
/ww:commit

# Or with PR
/ww:commit --pr
```

---

## Project Setup

### Scenario: Onboarding a new project

```bash
# Full setup
/ww:init

# Analyze and get recommendations
/ww:discover

# Installs recommended agents, sets up rules
```

### Scenario: Updating an existing project

```bash
# Re-analyze (project evolved)
/ww:discover

# Get fresh agent recommendations
```

---

## Workflow Troubleshooting

### Scenario: Something isn't working right

```bash
# Diagnose
/ww:improve

# Answers: "What went wrong?"
# Routes to: rule fix, agent edit, or bug report
```

---

## Managing Rules

### Scenario: Add a project convention

```bash
/rules:add project "Always use Arr::get() not array access"
```

### Scenario: Add feature-specific rule

```bash
/rules:add features/auth "Only use sanctum guards on API routes"
```

### Scenario: View all rules

/rules:show
```

---

## Agent Management

### Scenario: Install a specialist agent

```bash
/agents:search laravel
/agents:install laravel-specialist
```

### Scenario: List installed agents

```bash
/agents:list
```

---

## Command Quick Reference

| Need | Command |
|------|---------|
| New project | `/ww:init` |
| Analyze project | `/ww:discover` |
| Plan a feature | `/ww:plan` |
| Plan from issue | `/ww:plan --issue 42` |
| Execute plan | `/ww:do` |
| Execute issue | `/ww:do 42` |
| Just commit | `/ww:commit` |
| Audit codebase | `/ww:audit` |
| Deep audit | `/ww:audit --legacy` |
| Architecture | `/ww:arch brainstorm <topic>` |
| Fix workflow | `/ww:improve` |
| Add rule | `/rules:add project "..."` |
| Install agent | `/agents:install <name>` |
