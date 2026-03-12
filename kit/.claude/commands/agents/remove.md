# agents:remove

> Remove an installed agent.

**Usage:**
- `/agents:remove <n>` — Remove (searches local first, then global)
- `/agents:remove <n> --local` — Local only
- `/agents:remove <n> --global` — Global only
- `/agents:remove <n> --force` — Remove even if protected

**Protected agents (require --force):**
master-orchestrator, issue-executor, issue-creator, issue-closer, agent-installer, workflow-orchestrator

Invoke `agent-installer`:
> "Remove agent '$ARGUMENTS'. Check --local/--global/--force flags. Search for agent file in specified directory (default: local first, then global). IF agent is protected and no --force: refuse, explain why it's protected. ELSE: delete the file and confirm removal. List remaining agents in same category if applicable."
