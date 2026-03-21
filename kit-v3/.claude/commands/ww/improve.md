# ww:improve

> Diagnose workflow problems and suggest fixes. The self-improvement command.

**Usage:**
- `/ww:improve` — interactive diagnostics

## Steps

1. **Ask what went wrong**
   ```
   "What went wrong or what could be better?"
   ```

2. **Analyze the problem**
   - Read relevant workflow files (skills, rules, commands)
   - Identify root cause category

3. **Route to fix**

   | Problem Type | Action |
   |-------------|--------|
   | Rule gap | Suggest `/ww:rules-add` with exact text and placement reasoning |
   | Skill behavior | Open skill file, suggest specific edits, show diff |
   | Agent behavior | Open agent file, suggest specific edits, show diff |
   | Missing capability | Recommend `/ww:create skill` or `/ww:create agent` |
   | Quality gate issue | Check CLAUDE.md lint/test config, suggest fix |
   | Product bug | Create issue on tuti-cli/workflow-kit |

4. **Apply fix**
   - Show proposed change with reasoning
   - Wait for approval before applying
   - Never auto-modify system files

5. **Verify**
   - After applying: run relevant quality gate to confirm fix
   - If fix introduced new issues: rollback and report

## Examples

- "Tests aren't running before commit"
  → Check CLAUDE.md quality config → fix lint/test commands

- "Laravel skill suggests wrong pattern"
  → Open skill file → suggest edit → apply after approval

- "Same bug keeps happening"
  → Suggest creating a patch entry in `.workflow/execution/patches/`
  → Suggest adding a rule via `/ww:rules-add`
