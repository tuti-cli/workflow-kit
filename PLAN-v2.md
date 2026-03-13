# workflow-kit v2.0 Implementation Plan

> **Status:** Draft for Review
> **Created:** 2026-03-13
> **Estimated Total Effort:** ~23 hours

---

## Executive Summary

Transform the current workflow-kit MVP into a flexible, three-mode system that supports projects at all stages with:

- **Three Modes:** Scratch (minimal) → Growth (structured) → Mature (full features)
- **Layered Rules:** Base → Stack → Project → Feature inheritance
- **Agent Customization:** Template vars + context injection + content pruning
- **Stage Transitions:** Smooth migration with work preservation
- **Improved Planning:** Quick/Feature/Formal depth based on mode

---

## Current State Analysis

### What Works Well
- 6 core agents with clear separation of concerns
- Template variable system for project configuration
- Quality gates with tiered requirements
- Label-driven agent squad selection
- Integration with VoltAgent catalog

### Critical Issues
| Issue | Impact | Files Affected |
|-------|--------|----------------|
| Template format mismatch | Workflow can't parse issues | `ISSUE_TEMPLATE/*.yml` |
| Limited stack detection (6 stacks) | Wrong quality gates | `install.sh:106-167` |
| Label inconsistencies | Agent selection fails | `workflow-rules/SKILL.md` |
| Missing GitHub Actions | Manual process overhead | `.github/workflows/` |

---

## Phase 0: Fix Current MVP

**Priority:** Critical | **Effort:** 2h

### 0.1 Align Issue Templates

**Problem:** YAML templates don't include WORKFLOW META section that agents expect

**Solution:** Add hidden workflow metadata to template body

**Files to modify:**
```
kit/.github/ISSUE_TEMPLATE/feature.yml
kit/.github/ISSUE_TEMPLATE/bug.yml
kit/.github/ISSUE_TEMPLATE/chore.yml
kit/.github/ISSUE_TEMPLATE/docs.yml
```

**Example fix:**
```yaml
body:
  # ... existing fields ...

  - type: markdown
    attributes:
      value: |
        <!-- WORKFLOW META -->
        workflow_type: feature
        project_type: existing
        estimated_complexity: medium
```

### 0.2 Expand Stack Detection

**Problem:** Only detects 6 stacks, missing major ecosystems

**File to modify:** `install.sh` (lines 106-167)

**Add detection for:**

| Stack | Detection File | Lint Command | Test Command |
|-------|---------------|--------------|--------------|
| Go | `go.mod` | `golangci-lint run` | `go test ./...` |
| Ruby | `Gemfile` | `rubocop` | `rspec` |
| Rust | `Cargo.toml` | `cargo clippy` | `cargo test` |
| Java | `build.gradle` / `pom.xml` | `./gradlew lint` | `./gradlew test` |
| .NET | `*.csproj` | `dotnet format --verify` | `dotnet test` |

**Improve WordPress:**
- Detect Bedrock vs Standard
- Differentiate theme vs plugin development

### 0.3 Fix Label-Template Disconnect

**Problem:** Priority labels inconsistent (`priority:medium` vs `priority:normal`)

**Files to modify:**
- `kit/.claude/skills/workflow-rules/SKILL.md` - Standardize to `priority:medium`
- `scripts/setup-labels.sh` - Ensure all labels created

### 0.4 Add Missing GitHub Actions

**New files:**
```
kit/.github/workflows/stale.yml    # Auto-close inactive issues
kit/.github/workflows/test.yml     # Run tests on PRs (template)
```

**Verification:**
```bash
# Test template parsing
gh issue create --title "Test" --body-file test.md

# Test stack detection
./install.sh --detect-stack

# Test labels
./scripts/setup-labels.sh --dry-run
```

---

## Phase 1: Mode System Foundation

**Priority:** High | **Effort:** 4h

### 1.1 Mode Definitions

| Mode | Target | Overhead | Key Features |
|------|--------|----------|--------------|
| **Scratch** | New projects, prototypes | Minimal | Direct commits, basic quality, no formal issues |
| **Growth** | Active development | Moderate | GitHub issues, structured process, quality gates |
| **Mature** | Production systems | Full | Parallel agents, worktrees, team coordination |

### 1.2 Create Mode Configuration

**New file:** `kit/templates/config.yml`

```yaml
# .workflow/config.yml
version: "2.0"
mode: growth  # scratch | growth | mature

# Mode-specific settings
mode_config:
  scratch:
    direct_commits: true        # Allow commits without issues
    quality_level: basic        # lint only, tests optional
    auto_plan: true             # Generate quick plans
    branch_optional: true       # Can commit on main

  growth:
    direct_commits: false       # Require issues
    quality_level: standard     # lint + test required
    auto_plan: true             # Generate structured plans
    branch_required: true       # Must branch
    quality_gates:
      lint: true
      test: true
      coverage_threshold: null

  mature:
    direct_commits: false
    quality_level: strict       # lint + test + coverage
    auto_plan: false            # Require explicit planning
    branch_required: true
    quality_gates:
      lint: true
      test: true
      coverage_threshold: 80
    parallel_agents: true       # Enable multi-agent
    worktrees: true             # Enable worktree isolation

# Project metadata
project:
  name: ""
  stack: auto                   # auto-detect or explicit
  github_owner: ""
  github_repo: ""

# Quality gates (overridden by mode)
quality:
  lint_cmd: "composer lint"
  test_cmd: "composer test"
  coverage_cmd: null
```

### 1.3 Update Installer for Mode Detection

**File to modify:** `install.sh`

**New functions:**

```bash
# Detect appropriate mode for project
detect_mode() {
    local project_root="$1"
    local mode_file="$project_root/.workflow/config.yml"

    # Check existing config
    if [ -f "$mode_file" ]; then
        grep "^mode:" "$mode_file" | awk '{print $2}'
        return
    fi

    # Check commit count
    local commits=$(git -C "$project_root" rev-list --count HEAD 2>/dev/null || echo "0")

    # Check team size (unique authors)
    local authors=$(git -C "$project_root" shortlog -sn HEAD 2>/dev/null | wc -l || echo "1")

    # Check for CI/CD
    local has_ci="false"
    [ -f "$project_root/.github/workflows" ] && has_ci="true"

    # Determine mode
    if [ "$commits" -lt 50 ] && [ "$authors" -eq 1 ]; then
        echo "scratch"
    elif [ "$commits" -gt 200 ] && [ "$authors" -gt 3 ] && [ "$has_ci" = "true" ]; then
        echo "mature"
    else
        echo "growth"
    fi
}

# Create mode-specific directory structure
create_mode_structure() {
    local project_root="$1"
    local mode="$2"

    case "$mode" in
        scratch)
            mkdir -p "$project_root/.workflow"
            cp "$TEMPLATES_DIR/config-scratch.yml" "$project_root/.workflow/config.yml"
            ;;
        growth)
            mkdir -p "$project_root/.workflow"/{patches,ADRs,features,state}
            cp "$TEMPLATES_DIR/config-growth.yml" "$project_root/.workflow/config.yml"
            ;;
        mature)
            mkdir -p "$project_root/.workflow"/{patches,ADRs,features,state,plans,worktrees,team}
            cp "$TEMPLATES_DIR/config-mature.yml" "$project_root/.workflow/config.yml"
            ;;
    esac
}
```

### 1.4 Update master-orchestrator for Mode Awareness

**File to modify:** `kit/.claude/agents/master-orchestrator.md`

**Add at start of agent:**

```markdown
## Mode Detection (Pre-Flight)

Before any pipeline execution, detect project mode:

1. Read `.workflow/config.yml` → extract `mode`
2. If missing, default to `growth`

### Mode-Aware Pipeline Stages

| Stage | Scratch | Growth | Mature |
|-------|---------|--------|--------|
| SETUP | Skip (no issue) | Full | Full |
| IMPLEMENT | Direct | Structured | Parallel available |
| REVIEW | Skip | code-reviewer | code-reviewer + team review |
| QUALITY | Lint only | Lint + Test | Lint + Test + Coverage |
| COMMIT | Direct | Interactive | Interactive + review |
| PR | Optional | Required | Required + approval |
| CLOSE | Skip | Required | Required + summary |

### Skip Logic

**Scratch Mode:**
- Skip issue fetching (no issue required)
- Skip label management
- Run minimal quality (lint only)
- Allow direct main commits

**Growth Mode:**
- Full pipeline (current behavior)
- All quality gates required

**Mature Mode:**
- Full pipeline + coverage threshold
- Parallel agent execution available
- Worktree isolation available
```

**Verification:**
```bash
# Test mode detection
./install.sh --detect-mode /path/to/project

# Test scratch mode
/workflow:status  # Should show mode

# Test mode-specific pipeline
/workflow:issue 1  # Should follow mode rules
```

---

## Phase 2: Layered Rules System

**Priority:** High | **Effort:** 3h

### 2.1 Rules Hierarchy

```
┌─────────────────────────────────────────────┐
│ Layer 0: Base Rules                         │
│ Source: workflow-kit (immutable)            │
│ Always applied                              │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ Layer 1: Stack Rules                        │
│ Source: .claude/skills/stack-rules/{stack}/ │
│ Auto-loaded based on detected stack         │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ Layer 2: Project Rules                      │
│ Source: .workflow/rules.yml + CLAUDE.md     │
│ Team conventions, overrides                 │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ Layer 3: Feature Rules                      │
│ Source: .workflow/features/{N}-rules.md     │
│ Temporary, per-feature overrides            │
└─────────────────────────────────────────────┘
```

### 2.2 Rules Configuration File

**New file:** `kit/templates/rules.yml`

```yaml
# .workflow/rules.yml
# Layered rules configuration

# Base rules (from workflow-kit, immutable)
base:
  version: "2.0"
  source: tuti-cli/workflow-kit

# Stack rules (auto-loaded based on detected stack)
stack:
  active: laravel              # Auto-detected or manual
  rules:
    - strict_types_always
    - final_classes_preferred
    - pest_over_phpunit
  quality:
    lint: "composer lint"
    test: "composer test"
    lint_after_edit: true

# Project overrides (custom rules)
project:
  rules:
    - constructor_injection_only
    - no_facades_in_services
  quality:
    coverage_threshold: 80
    forbid_skipped_tests: true
  conventions:
    branch_prefix: "feature/"
    commit_scope_required: true

# Feature rules (temporary, per-feature)
features:
  "123":                       # Issue #123
    expires: "2026-03-20"
    rules:
      - wip_commits_allowed
      - skip_coverage_check
```

### 2.3 Create Stack Rules Files

**Directory structure:**
```
kit/.claude/skills/stack-rules/
├── laravel/
│   └── SKILL.md
├── react/
│   └── SKILL.md
├── vue/
│   └── SKILL.md
├── node/
│   └── SKILL.md
├── python/
│   └── SKILL.md
└── generic/
    └── SKILL.md
```

**Example:** `kit/.claude/skills/stack-rules/laravel/SKILL.md`

```markdown
---
name: stack-rules-laravel
description: "Laravel-specific rules and conventions"
stack: laravel
---

# Laravel Stack Rules

## Code Standards
- `declare(strict_types=1);` at top of every PHP file
- Final classes preferred unless explicitly designed for inheritance
- Constructor injection only — no Facades in service classes
- Return types required on all public methods

## Quality Gates
```bash
composer lint    # Laravel Pint
composer test    # Pest
```

## Testing Conventions
- Pest over PHPUnit
- Feature tests for HTTP endpoints
- Unit tests for services
- Arch tests for architecture constraints

## Directory Conventions
```
app/
├── Domain/           # Domain logic
├── Application/      # Use cases
├── Infrastructure/   # External integrations
└── Presentation/     # Controllers, Requests
```

## Forbidden Patterns
- No `env()` outside config files
- No Facades in Domain layer
- No `DB::raw()` without review
```

### 2.4 Rules Loading Algorithm

**Add to master-orchestrator.md:**

```markdown
## Rules Loading

Before any implementation, load rules in order:

### 1. Load Base Rules (always)
```bash
cat .claude/skills/workflow-rules/SKILL.md
```

### 2. Load Stack Rules (if exists)
```bash
STACK=$(grep "stack:" .workflow/config.yml | awk '{print $2}')
cat .claude/skills/stack-rules/$STACK/SKILL.md
```

### 3. Load Project Rules (if exists)
```bash
cat .workflow/rules.yml
cat CLAUDE.md  # Extract conventions section
```

### 4. Load Feature Rules (if applicable)
```bash
ISSUE_N=123
cat .workflow/features/$ISSUE_N-rules.md
```

### Merge Strategy
- Arrays: Append unique values
- Scalars: Child overrides parent
- Maps: Deep merge, child wins conflicts
```

**Verification:**
```bash
# Test rules loading
/workflow:status  # Should show active rules layers

# Test stack rules
/workflow:issue 1  # Should apply Laravel rules for Laravel project
```

---

## Phase 3: Agent Customization Pipeline

**Priority:** High | **Effort:** 4h

### 3.1 Pipeline Overview

```
┌──────────────┐    ┌─────────────────┐    ┌────────────────┐
│   FETCH      │───▶│ TEMPLATE VARS   │───▶│ CONTEXT INJECT │
│   (raw)      │    │   REPLACE       │    │                │
└──────────────┘    └─────────────────┘    └───────┬────────┘
                                                    │
                                                    ▼
┌──────────────┐    ┌─────────────────┐    ┌────────────────┐
│   SAVE       │◀───│   CONTENT       │◀───│    PRUNE       │
│   (final)    │    │   VALIDATE      │    │                │
└──────────────┘    └─────────────────┘    └────────────────┘
```

### 3.2 Customization Configuration

**New file:** `kit/templates/agent-customization.yml`

```yaml
# .workflow/agent-customization.yml
# Agent customization settings

# Template variables (auto-populated)
template_vars:
  GITHUB_OWNER: ""             # From CLAUDE.md
  GITHUB_REPO: ""              # From CLAUDE.md
  STACK: ""                    # Auto-detected
  QUALITY_GATE_LINT: ""        # Auto-detected
  QUALITY_GATE_TEST: ""        # Auto-detected

# Context injection settings
context_injection:
  enabled: true
  sources:
    - CLAUDE.md                # Always read
    - .workflow/PROJECT.md     # If exists
    - .workflow/rules.yml      # If exists
  inject_sections:
    - "## Tech Stack"
    - "## Code Conventions"
    - "## Quality Gates"
    - "## Project-Specific Notes"

# Content pruning
pruning:
  enabled: true
  rules:
    - match: "## Docker"
      condition: "no_docker_compose"
      action: remove_section

    - match: "## WordPress Integration"
      condition: "not_wordpress"
      action: remove_section

    - match: "\\{\\{.*\\}\\}"
      condition: "template_var_missing"
      action: comment_out_line

# Agent-specific customizations
agents:
  php-pro:
    prune_sections:
      - "## WordPress Integration"
      - "## Symfony Integration"

  laravel-specialist:
    inject_conventions: true
    prune_sections:
      - "## Lumen Support"
```

### 3.3 Rewrite agent-installer.md

**File to modify:** `kit/.claude/agents/agent-installer.md`

**New content:**

```markdown
---
name: agent-installer
description: "Install Claude Code agents from VoltAgent catalog with automatic customization for your project."
tools: Bash, WebFetch, Read, Write, Glob, Grep, Edit
model: haiku
---

You are the Agent Installer. You install and customize Claude Code agents from the VoltAgent catalog.

## Customization Pipeline

When installing an agent, follow this pipeline:

### Stage 1: FETCH
1. Download raw agent from catalog:
   `https://raw.githubusercontent.com/VoltAgent/awesome-claude-code-subagents/main/categories/{category}/{name}.md`
2. Store in temporary location: `.workflow/tmp/{name}.md`

### Stage 2: TEMPLATE VARS
Replace all template variables:

| Variable | Source |
|----------|--------|
| `{{GITHUB_OWNER}}` | CLAUDE.md or .workflow/config.yml |
| `{{GITHUB_REPO}}` | CLAUDE.md or .workflow/config.yml |
| `{{GITHUB_OWNER}}/{{GITHUB_REPO}}` | Combined |
| `{{STACK}}` | Detected stack |
| `{{QUALITY_GATE_LINT}}` | Detected lint command |
| `{{QUALITY_GATE_TEST}}` | Detected test command |

Use sed for replacement:
```bash
sed -i "s|{{GITHUB_OWNER}}|$OWNER|g" "$TMP_FILE"
sed -i "s|{{GITHUB_REPO}}|$REPO|g" "$TMP_FILE"
# etc.
```

### Stage 3: CONTEXT INJECT
If `.workflow/agent-customization.yml` exists with `context_injection.enabled: true`:

1. Read sources specified in inject_sections:
   - Extract sections from CLAUDE.md
   - Read PROJECT.md if exists
   - Read rules.yml if exists

2. Inject project context into agent after frontmatter:
```markdown
<!-- PROJECT CONTEXT (injected by workflow-kit) -->
## Project Context

### Tech Stack
[content from CLAUDE.md ## Tech Stack section]

### Code Conventions
[content from CLAUDE.md ## Code Conventions section]

### Quality Gates
- Lint: `[injected command]`
- Test: `[injected command]`

<!-- END PROJECT CONTEXT -->
```

### Stage 4: PRUNE
If `pruning.enabled: true`:

1. Check each section against pruning rules
2. Evaluate conditions:
   - `no_docker_compose`: `[ ! -f "docker-compose.yml" ]`
   - `not_wordpress`: `[ ! -f "wp-config.php" ]`
   - `template_var_missing`: grep for remaining `{{.*}}`
3. Remove or modify sections that match
4. Comment out lines with missing template vars

### Stage 5: VALIDATE
1. Verify frontmatter is valid YAML
2. Check required fields exist (name, description, tools, model)
3. Validate no broken template vars remain
4. Report any issues

### Stage 6: SAVE
1. Determine save location:
   - Local: `.claude/agents/`
   - Global: `~/.claude/agents/`
2. Write final file
3. Log customization summary

## Output Format

After installation:
```
✓ Installed {name}.md to {path}

Customization applied:
  ✓ Template vars: 5 replaced
  ✓ Context injected: 4 sections
  ✓ Pruned: 2 sections removed

Sections removed:
  - "## WordPress Integration" (not applicable)
  - "## Legacy PHP Support" (not applicable)
```

## Commands

### /agents:install
```
/agents:install docker-expert          # Install with customization
/agents:install docker-expert --global # Install globally
/agents:install docker-expert --no-customize  # Skip customization
```

### /agents:customize (NEW)
Re-apply customization pipeline to existing agent:
```
/agents:customize php-pro              # Re-customize
/agents:customize php-pro --no-prune   # Skip pruning
```
```

### 3.4 Create Customize Command

**New file:** `kit/.claude/commands/agents/customize.md`

```markdown
# agents:customize

> Re-apply customization pipeline to an installed agent.

**Usage:**
- `/agents:customize <name>` — Re-customize with current project context
- `/agents:customize <name> --no-prune` — Skip pruning step
- `/agents:customize <name> --no-inject` — Skip context injection

**What it does:**
1. Reads existing agent from `.claude/agents/{name}.md`
2. Fetches fresh context from CLAUDE.md, PROJECT.md, rules.yml
3. Re-applies template variable replacement
4. Re-injects project context
5. Re-applies pruning rules
6. Saves updated agent

Invoke `agent-installer`:
> "Re-customize agent '$ARGUMENTS'. Read existing agent from .claude/agents/{name}.md or ~/.claude/agents/{name}.md. Check for --no-prune and --no-inject flags. Fetch fresh project context from CLAUDE.md and .workflow/ files. Re-apply template vars, context injection (unless --no-inject), and pruning (unless --no-prune). Save to same location. Report customization summary."
```

**Verification:**
```bash
# Test agent installation with customization
/agents:install php-pro
cat .claude/agents/php-pro.md  # Should have project context

# Test re-customization
/agents:customize php-pro

# Test without customization
/agents:install docker-expert --no-customize
```

---

## Phase 4: Stage Transitions

**Priority:** Medium | **Effort:** 3h

### 4.1 Transition Readiness Indicators

**Scratch → Growth:**
| Indicator | Threshold | Weight |
|-----------|-----------|--------|
| Commit count | ≥ 50 | 2 |
| GitHub remote | Configured | 2 |
| Team size | ≥ 2 | 1 |
| Has CI/CD | Yes | 1 |
| Has production | Yes | 2 |
| **Trigger:** | Score ≥ 5 | |

**Growth → Mature:**
| Indicator | Threshold | Weight |
|-----------|-----------|--------|
| Commit count | ≥ 200 | 2 |
| Team size | ≥ 5 | 2 |
| Multiple contributors | Yes | 2 |
| Coverage | ≥ 80% | 2 |
| Formal planning | Yes | 1 |
| Parallel work needed | Yes | 2 |
| **Trigger:** | Score ≥ 8 | |

### 4.2 Create Transition Agent

**New file:** `kit/.claude/agents/workflow-transitioner.md`

```markdown
---
name: workflow-transitioner
description: "Handles mode transitions, creates migration artifacts, preserves work when moving between Scratch/Growth/Mature modes."
github:
  owner: {{GITHUB_OWNER}}
  repo: {{GITHUB_REPO}}
  full: {{GITHUB_OWNER}}/{{GITHUB_REPO}}
tools: Read, Write, Bash, Glob, Grep, mcp__github__*
model: sonnet
---

You are the Workflow Transitioner. You handle mode transitions with work preservation.

## Transition Checklist

### Scratch → Growth

**Pre-conditions:**
- [ ] Has GitHub remote configured
- [ ] CLAUDE.md has GitHub Repository section
- [ ] `gh` CLI authenticated

**Migration Steps:**

1. **Create Initial Issues from Commits**
   ```bash
   # From recent commits (last 20)
   git log --oneline -20 --pretty=format:"%s" | while read msg; do
     gh issue create --title "$msg" --body "Migrated from commit history during Scratch→Growth transition." --label "type:chore,status:ready"
   done
   ```

2. **Create .workflow/ Structure**
   ```bash
   mkdir -p .workflow/{patches,ADRs,features,state}
   ```

3. **Create .github/ Templates**
   - Copy ISSUE_TEMPLATE/
   - Copy PULL_REQUEST_TEMPLATE.md

4. **Update config.yml**
   ```yaml
   mode: growth
   ```

5. **Run Label Setup**
   ```bash
   ./scripts/setup-labels.sh
   ```

6. **Create PROJECT.md**
   - Document current architecture
   - List conventions discovered

**Preserve:**
- All existing files
- Git history
- .claude/ agents (add to them, don't replace)

### Growth → Mature

**Pre-conditions:**
- [ ] 200+ commits
- [ ] 5+ contributors or team members
- [ ] CI/CD configured
- [ ] Coverage > 80%

**Migration Steps:**

1. **Create plans/ structure**
   ```bash
   mkdir -p .workflow/{plans,worktrees,team}
   ```

2. **Enable parallel execution**
   - Update config.yml with `parallel_agents: true`
   - Add team/ commands

3. **Create team/ coordination files**
   ```bash
   # .workflow/team/coordination.yml
   parallel_execution: true
   max_parallel_agents: 3
   worktree_prefix: ".claude/worktrees"
   ```

4. **Backfill ADRs**
   - Analyze git history for major decisions
   - Create ADRs for significant changes

5. **Update config.yml**
   ```yaml
   mode: mature
   parallel_agents: true
   worktrees: true
   ```

**Preserve:**
- All issues, patches, ADRs
- Quality gate configuration
- Agent customizations
```

### 4.3 Create Transition Command

**New file:** `kit/.claude/commands/workflow/transition.md`

```markdown
# workflow:transition

> Transition project to a different workflow mode with work preservation.

**Usage:**
- `/workflow:transition` — Check readiness and suggest transition
- `/workflow:transition growth` — Transition to Growth mode
- `/workflow:transition mature` — Transition to Mature mode
- `/workflow:transition --dry-run` — Preview changes without applying
- `/workflow:transition --force` — Transition even if not ready

**What it does:**
1. Analyzes current project state
2. Checks transition readiness
3. Lists what will change
4. Creates migration artifacts
5. Preserves existing work
6. Updates configuration

Invoke `workflow-transitioner`:
> "GITHUB REPO: owner={{GITHUB_OWNER}} repo={{GITHUB_REPO}}. Analyze project for mode transition. IF no target mode specified: show current mode, calculate readiness score, suggest next mode. IF target mode specified: check pre-conditions, list migration steps, IF --dry-run: show preview only. ELSE: execute migration with work preservation. Create backup of config before changes. Report summary of changes made."
```

### 4.4 Update Status Command

**File to modify:** `kit/.claude/commands/workflow/status.md`

**Add to output:**

```markdown
**Output:**
```
════════════════════════════════════════
  workflow-kit Status
════════════════════════════════════════

Mode:          Growth (ready for Mature)
Version:       2.0.0
Stack:         Laravel
GitHub:        myorg/myproject

Mode Indicators:
  ✓ Commits:         156 (threshold: 200)
  ✓ Contributors:    4 (threshold: 5)
  ✓ Coverage:        85% (threshold: 80%)
  ✓ CI/CD:           Configured
  ✓ Parallel work:   2 active branches

Transition Suggestion:
  Ready for Mature mode!
  Run: /workflow:transition mature --dry-run

[... rest of existing output ...]
```
```

**Verification:**
```bash
# Test transition check
/workflow:transition

# Test dry-run
/workflow:transition growth --dry-run

# Test actual transition (with backup)
/workflow:transition growth
```

---

## Phase 5: Planning System Improvements

**Priority:** Medium | **Effort:** 3h

### 5.1 Planning Depth by Mode

| Mode | Plan Type | Depth | Time | Artifacts |
|------|-----------|-------|------|-----------|
| Scratch | Quick | Goals + steps + files | 1-2 min | PLAN.md (ephemeral) |
| Growth | Feature | Full plan with phases | 5-10 min | feature-N.md |
| Mature | Formal | Plan + ADR + review | 15-30 min | PLAN-N.md + ADR |

### 5.2 Create Planning Specialist Agent

**New file:** `kit/.claude/agents/planning-specialist.md`

```markdown
---
name: planning-specialist
description: "Creates detailed implementation plans, ADRs, and technical designs. Invoked for complex features in Growth/Mature modes."
tools: Read, Glob, Grep, Bash, mcp__github__*
model: sonnet
---

You are the Planning Specialist. You create implementation plans.

## Plan Depth by Mode

| Mode | Plan Type | Depth | Time |
|------|-----------|-------|------|
| Scratch | Quick | Goals, steps, files | 1-2 min |
| Growth | Feature | Full plan with phases | 5-10 min |
| Mature | Formal | Plan + ADR + review | 15-30 min |

## Planning Process

### 1. Gather Context
1. Read issue completely
2. Read CLAUDE.md for conventions
3. Read relevant patches (`.workflow/patches/INDEX.md`)
4. Read relevant ADRs
5. Analyze codebase structure

### 2. Identify Scope
- Files affected
- Components touched
- Breaking changes
- Dependencies

### 3. Design Solution
- Architecture approach
- Implementation phases
- Test strategy
- Rollback plan

### 4. Create Artifacts

**Growth Mode:**
- `.workflow/features/feature-N.md` (plan)
- GitHub comment with plan

**Mature Mode:**
- `.workflow/plans/PLAN-N.md` (detailed plan)
- `.workflow/ADRs/NNN-title.md` (if requested)
- GitHub comment with plan + ADR link
```

### 5.3 Create Quick Commands (Scratch Mode)

**New files:**

`kit/.claude/commands/quick/plan.md`:
```markdown
# quick:plan

> Generate a quick implementation plan for direct execution.

**Usage:**
- `/quick:plan` — Analyze and plan for current task
- `/quick:plan "description"` — Plan specific task

**Output:** `.workflow/PLAN.md` (ephemeral, overwritten each time)

Invoke `planning-specialist`:
> "Create a QUICK plan (Scratch mode depth). Analyze current context or use description from '$ARGUMENTS'. Output to .workflow/PLAN.md with: Goal (1-2 sentences), Approach (3-5 steps), Files to Change (list), Risks (if any). Keep under 50 lines. Suggest /quick:implement to execute."
```

`kit/.claude/commands/quick/implement.md`:
```markdown
# quick:implement

> Execute the quick plan from .workflow/PLAN.md.

**Usage:**
- `/quick:implement` — Execute plan
- `/quick:implement --dry-run` — Preview only

Invoke `master-orchestrator`:
> "Execute quick implementation from .workflow/PLAN.md. Read the plan. Implement changes. Run lint after each file edit. Do NOT create issue, branch, or PR (Scratch mode). When done, suggest /quick:commit."
```

`kit/.claude/commands/quick/commit.md`:
```markdown
# quick:commit

> Create a quick commit (Scratch mode).

**Usage:**
- `/quick:commit` — Commit with auto-generated message
- `/quick:commit "message"` — Commit with specific message

Invoke `master-orchestrator`:
> "Create a quick commit. Run lint. Stage all changes. Generate conventional commit message from changes. Commit. No PR creation (Scratch mode)."
```

### 5.4 Create Formal Plan Command (Mature Mode)

**New file:** `kit/.claude/commands/workflow/plan.md`

```markdown
# workflow:plan

> Create a detailed, reviewed plan with optional ADR for complex features.

**Usage:**
- `/workflow:plan <N>` — Create plan for issue #N
- `/workflow:plan <N> --adr` — Also create ADR
- `/workflow:plan <N> --review` — Request plan review

**Output:**
- `.workflow/plans/PLAN-N.md`
- `.workflow/ADRs/NNN-title.md` (if --adr)
- GitHub comment with plan

Invoke `planning-specialist`:
> "GITHUB REPO: owner={{GITHUB_OWNER}} repo={{GITHUB_REPO}}. Create FORMAL plan for issue #$ARGUMENTS. Read issue, patches, ADRs. Analyze codebase. Create detailed plan with: Problem Statement, Proposed Solution, Architecture Impact, Implementation Phases (with estimates), Test Strategy, Rollback Plan, Alternatives Considered. IF --adr: create ADR linked to plan. IF --review: post plan as GitHub comment requesting review. Post plan link on issue."
```

**Verification:**
```bash
# Test quick plan (Scratch)
/quick:plan "Add user authentication"
cat .workflow/PLAN.md

# Test feature plan (Growth)
/workflow:issue 1 --dry-run  # Should show structured plan

# Test formal plan (Mature)
/workflow:plan 1 --adr
cat .workflow/plans/PLAN-1.md
cat .workflow/ADRs/*.md
```

---

## Phase 6: Mature Mode Features (Future)

**Priority:** Low | **Effort:** 4h

### 6.1 Team Coordination Commands

**New files:**

`kit/.claude/commands/team/parallel.md`:
```markdown
# team:parallel

> Execute multiple issues in parallel with isolated agents.

**Usage:**
- `/team:parallel 1 2 3` — Execute issues 1, 2, 3 in parallel
- `/team:parallel 1-5` — Execute issues 1-5 in parallel

Each issue gets:
- Isolated worktree
- Dedicated agent
- Separate branch
```

`kit/.claude/commands/team/worktree.md`:
```markdown
# team:worktree

> Manage worktrees for parallel execution.

**Usage:**
- `/team:worktree create <N>` — Create worktree for issue #N
- `/team:worktree list` — List active worktrees
- `/team:worktree remove <N>` — Remove worktree after merge
```

`kit/.claude/commands/team/sync.md`:
```markdown
# team:sync

> Synchronize parallel work (rebase worktrees on main changes).

**Usage:**
- `/team:sync` — Sync all active worktrees
- `/team:sync <N>` — Sync specific worktree
```

### 6.2 Coordination Skill

**New file:** `kit/.claude/skills/coordination/SKILL.md`

```markdown
---
name: coordination
description: "Team coordination rules for parallel execution"
---

# Team Coordination Rules

## Parallel Execution
- Max 3 concurrent agents
- Each agent in isolated worktree
- No shared state between agents
- Auto-sync on main changes

## Conflict Resolution
- Auto-rebase on conflicts
- Escalate if conflicts persist
- Never force push

## Resource Limits
- Max 3 worktrees
- Cleanup after merge
- Monitor memory usage
```

---

## Implementation Summary

### Files to Modify (13 files)

| File | Changes |
|------|---------|
| `install.sh` | Mode detection, expanded stack detection |
| `kit/.claude/agents/master-orchestrator.md` | Mode awareness, rules loading |
| `kit/.claude/agents/agent-installer.md` | Complete rewrite with customization pipeline |
| `kit/.claude/skills/workflow-rules/SKILL.md` | Label standardization |
| `kit/.claude/commands/workflow/status.md` | Mode and transition display |
| `kit/.github/ISSUE_TEMPLATE/feature.yml` | Add WORKFLOW META |
| `kit/.github/ISSUE_TEMPLATE/bug.yml` | Add WORKFLOW META |
| `kit/.github/ISSUE_TEMPLATE/chore.yml` | Add WORKFLOW META |
| `kit/.github/ISSUE_TEMPLATE/docs.yml` | Add WORKFLOW META |
| `scripts/setup-labels.sh` | Label consistency |
| `kit/WORKFLOW.md` | Document new features |
| `CLAUDE.md` | Document mode system |
| `README.md` | Update feature list |

### New Files to Create (27 files)

**Phase 0-1:**
- `kit/templates/config-scratch.yml`
- `kit/templates/config-growth.yml`
- `kit/templates/config-mature.yml`
- `kit/.github/workflows/stale.yml`
- `kit/.github/workflows/test.yml`

**Phase 2:**
- `kit/templates/rules.yml`
- `kit/.claude/skills/stack-rules/laravel/SKILL.md`
- `kit/.claude/skills/stack-rules/react/SKILL.md`
- `kit/.claude/skills/stack-rules/vue/SKILL.md`
- `kit/.claude/skills/stack-rules/node/SKILL.md`
- `kit/.claude/skills/stack-rules/python/SKILL.md`
- `kit/.claude/skills/stack-rules/generic/SKILL.md`

**Phase 3:**
- `kit/templates/agent-customization.yml`
- `kit/.claude/commands/agents/customize.md`

**Phase 4:**
- `kit/.claude/agents/workflow-transitioner.md`
- `kit/.claude/commands/workflow/transition.md`

**Phase 5:**
- `kit/.claude/agents/planning-specialist.md`
- `kit/.claude/commands/quick/plan.md`
- `kit/.claude/commands/quick/implement.md`
- `kit/.claude/commands/quick/commit.md`
- `kit/.claude/commands/workflow/plan.md`

**Phase 6:**
- `kit/.claude/commands/team/parallel.md`
- `kit/.claude/commands/team/worktree.md`
- `kit/.claude/commands/team/sync.md`
- `kit/.claude/skills/coordination/SKILL.md`

### Effort Summary

| Phase | Priority | Effort | Dependencies |
|-------|----------|--------|--------------|
| 0: Fix MVP | Critical | 2h | None |
| 1: Modes | High | 4h | Phase 0 |
| 2: Rules | High | 3h | Phase 1 |
| 3: Customization | High | 4h | Phase 2 |
| 4: Transitions | Medium | 3h | Phase 1, 2 |
| 5: Planning | Medium | 3h | Phase 1 |
| 6: Mature | Low | 4h | Phase 4, 5 |
| **Total** | | **23h** | |

---

## Verification Checklist

After each phase, verify:

### Phase 0
- [ ] Issue templates parse correctly with WORKFLOW META
- [ ] All 11 stacks detected correctly
- [ ] Labels created match workflow-rules
- [ ] Stale workflow runs on test repo

### Phase 1
- [ ] `/workflow:status` shows correct mode
- [ ] Mode detection works for new/existing projects
- [ ] Scratch mode allows direct commits
- [ ] Growth mode enforces branching

### Phase 2
- [ ] Rules loaded in correct order (base → stack → project → feature)
- [ ] Stack rules applied based on detected stack
- [ ] Project rules override stack rules
- [ ] Feature rules temporary and expire

### Phase 3
- [ ] `/agents:install` customizes with project context
- [ ] Template vars replaced correctly
- [ ] Irrelevant sections pruned
- [ ] `/agents:customize` re-applies customization

### Phase 4
- [ ] `/workflow:transition` detects readiness correctly
- [ ] Scratch → Growth creates issues from commits
- [ ] Growth → Mature creates team structure
- [ ] Work preserved during transition

### Phase 5
- [ ] `/quick:plan` generates quick plan
- [ ] `/quick:implement` executes plan
- [ ] `/workflow:plan` creates detailed plan with ADR

### Phase 6
- [ ] `/team:parallel` executes issues in parallel
- [ ] Worktrees isolated and cleaned up
- [ ] Conflict resolution works

---

## Risks and Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Breaking existing projects | Medium | High | Phase 0 ensures backward compatibility |
| Mode detection incorrect | Low | Medium | Manual override in config.yml |
| Customization removes needed content | Medium | Medium | Validation step + --no-customize flag |
| Transitions lose work | Low | High | Migration artifacts + backup |
| Rules conflicts | Medium | Low | Clear precedence documented |

---

## Next Steps

1. **Review this plan** - Discuss any changes needed
2. **Approve plan** - Ready to start implementation
3. **Start Phase 0** - Fix current MVP issues first
4. **Iterate** - Complete each phase, verify, move to next
