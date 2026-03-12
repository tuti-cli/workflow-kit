# agents:install

> Install an agent from the VoltAgent catalog.

**Usage:**
- `/agents:install <n>` — Install locally (`.claude/agents/`)
- `/agents:install <n> --global` — Install globally (`~/.claude/agents/`)

**Source:** https://github.com/VoltAgent/awesome-claude-code-subagents

Invoke `agent-installer`:
> "Install agent '$ARGUMENTS' from awesome-claude-code-subagents. Check for --global or --local flag (default: local). Find the correct category by searching README. Fetch from https://raw.githubusercontent.com/VoltAgent/awesome-claude-code-subagents/main/categories/{category}/{name}.md. Save to .claude/agents/ (local) or ~/.claude/agents/ (global). Verify file saved. Confirm: ✓ Installed {name}.md to {path}."
