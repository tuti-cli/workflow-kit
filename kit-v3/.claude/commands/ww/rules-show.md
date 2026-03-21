# ww:rules-show

> Display active rules organized by layer and priority.

**Usage:**
- `/ww:rules-show` — show all rules
- `/ww:rules-show base` — show base layer only
- `/ww:rules-show project` — show project layer only
- `/ww:rules-show features` — show feature layers
- `/ww:rules-show hard` — show hard rules from CLAUDE.md

## Steps

1. **Collect rules by layer**

   **Hard rules (highest priority):**
   - Read CLAUDE.md Non-Negotiable Rules section

   **Feature rules:**
   - Read `.claude/rules/features/*.md`

   **Project rules:**
   - Read `.claude/rules/project/*.md`

   **Base rules (lowest priority):**
   - Read `.claude/rules/base/*.md`

2. **Display**

   If specific layer requested: show only that layer.
   If `hard`: show only CLAUDE.md rules.
   If no argument: show all, organized by priority:

   ```
   Active Rules
   ============

   HARD RULES (CLAUDE.md — always enforced)
   ─────────────────────────────────────────
   - Run lint before every commit
   - Never commit failing tests
   - Conventional commits format
   ...

   FEATURE RULES (highest soft priority)
   ──────────────────────────────────────
   [features/auth.md]
   - Only use sanctum guards on API routes
   ...

   PROJECT RULES
   ─────────────
   [project/conventions.md]
   - Always use Arr::get() not array access
   ...

   BASE RULES (lowest priority)
   ────────────────────────────
   [base/git.md]
   - Branch from main
   - Conventional commit format
   ...

   Priority: Hard > Features > Project > Base
   Conflicts: higher priority wins
   ```
