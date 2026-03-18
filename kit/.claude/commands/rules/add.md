# rules:add

> Add a rule to the project. Creates or updates rule files in .claude/rules/.

**Usage:**
- `/rules:add project "rule text"` — add to project conventions
- `/rules:add features/<name> "rule text"` — add to feature rules

**What it does:**
1. Parse the rule text
2. Determine target layer (project or features)
3. Append to appropriate file in `.claude/rules/`
4. Confirm where rule was added

**Layers (in priority order):**
```
features/<name>.md   ← highest priority
project/conventions.md
base/coding-standards.md
```

**Examples:**
```
/rules:add project "Always use Arr::get() not array access"
/rules:add features/auth "Only use sanctum guards on API routes"
```

**After adding:**
Rules are automatically loaded by Claude Code. No sync needed.

> "Run /rules:add. Parse the rule and target layer. Append to appropriate file in .claude/rules/. Confirm the rule was added with file path."
