# agents:list

> List all installed agents with location and description.

**Usage:**
- `/agents:list` — All agents (local + global)
- `/agents:list --local` — Local only (.claude/agents/)
- `/agents:list --global` — Global only (~/.claude/agents/)

Invoke `agent-installer`:
> "List all installed Claude Code agents. Glob .claude/agents/*.md for local agents. Glob ~/.claude/agents/*.md for global agents. IF --local: show only local. IF --global: show only global. ELSE: show both. For each agent, extract name and description from YAML frontmatter. Present as table: Agent | Location | Description. Show total count and note protected agents."
