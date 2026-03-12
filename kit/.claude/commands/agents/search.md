# agents:search

> Search for agents in the VoltAgent catalog.

**Usage:**
- `/agents:search <query>` — Search by keyword
- `/agents:search <query> --category <cat>` — Search within category

**Categories:**
- 01-core-development, 02-language-specialists, 03-infrastructure
- 04-quality-security, 05-data-ai, 06-developer-experience
- 07-specialized-domains, 08-business-product, 09-meta-orchestration, 10-research-analysis

Invoke `agent-installer`:
> "Search for agents matching '$ARGUMENTS' in awesome-claude-code-subagents. Fetch README from https://raw.githubusercontent.com/VoltAgent/awesome-claude-code-subagents/main/README.md. Filter by query in agent names and descriptions. IF --category flag: filter to that category only. Show up to 20 results as table: agent | description | category. Suggest /agents:install <name> for each result."
