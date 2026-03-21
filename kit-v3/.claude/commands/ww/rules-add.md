# ww:rules-add

> Add a rule with placement validation. Determines hard vs soft rule automatically.

**Usage:**
- `/ww:rules-add project "rule text"` — add to project conventions
- `/ww:rules-add features/<name> "rule text"` — add to feature rules

## Steps

1. **Parse the rule text**

2. **Validate placement — hard vs soft**
   ```
   "If Claude forgets this rule, does something break?"
   → Yes, breaks = hard rule → suggest CLAUDE.md
   → No, just gets ugly = soft rule → suggest rules/
   ```

3. **If hard rule → suggest CLAUDE.md**
   ```
   This is a [quality/git/security] rule. If forgotten:
   [explain what breaks].

   Recommend: Add to CLAUDE.md Non-Negotiable Rules section.
   → Approve | Move to soft rule instead | Cancel
   ```
   - If approved: append to appropriate section in CLAUDE.md

4. **If soft rule → determine layer**
   - If target specified (`project`, `features/auth`): use that
   - If not specified, suggest based on content:
     - Universal across all projects → `rules/base/` (warn: this affects all projects)
     - This project only → `rules/project/conventions.md`
     - Specific subsystem → `rules/features/<name>.md`

   ```
   This is a project convention. Suggest:
   → rules/project/conventions.md

   Approve? [Y / Change location / Cancel]
   ```

5. **Apply**
   - Append rule to target file
   - Confirm with file path

6. **Verify**
   - Rules in `rules/` auto-load — no sync needed
   - Hard rules in CLAUDE.md are always present
