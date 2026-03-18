# rules:show

> Display active rules. Shows all loaded rules or specific layers.

**Usage:**
- `/rules:show` — show all rules
- `/rules:show base` — show base layer only
- `/rules:show project` — show project layer only
- `/rules:show features` — show feature layers

**What it does:**
1. Read rules from `.claude/rules/`
2. Display organized by layer
3. Show priority order (features > project > base)

**Layer priority:**
```
.features/<name>.md   ← highest
.claude/rules/project/
.claude/rules/base/   ← lowest
```

**What it shows:**
- Base: coding standards, git rules, testing, architecture
- Project: stack config, conventions, architecture decisions
- Features: auth, payments, api, etc.

> "Run /rules:show. IF no argument: show all rules organized by layer. IF layer specified: show only that layer. Display priority order."
