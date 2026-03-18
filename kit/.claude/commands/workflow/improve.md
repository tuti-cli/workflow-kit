# workflow:improve

> Diagnose and fix workflow issues. The self-improvement command.

**Usage:**
- `/ww:improve` — interactive diagnostics

**What it does:**
1. Ask: "What went wrong?"
2. Analyze the problem
3. Route to the right fix:
   - **Rule gap** → suggest `/rules:add project "..."` with exact text
   - **Agent behavior** → open agent file, suggest edits
   - **Product bug** → create issue on workflow-kit repo
   - **Missing capability** → recommend agent install or feature request

**Examples:**
- "Tests aren't running before commit" → check quality config, fix lint/test commands
- "Agent keeps doing X wrong" → suggest agent file edit
- "Same bug keeps happening" → recommend patch-writer capture

Invoke `project-analyst`:
> "Run /ww:improve. Ask user 'What went wrong?'. Analyze and route: IF rule gap: suggest /rules:add with specific text. IF agent behavior issue: open agent file, suggest edits. IF product bug: create issue on tuti-cli/workflow-kit. IF missing capability: recommend agent install or feature request."
