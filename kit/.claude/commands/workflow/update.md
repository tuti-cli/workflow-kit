# workflow:update

> Pull latest updates from workflow-kit repository.

**Usage:**
- `/workflow:update` — Check and apply updates
- `/workflow:update --check` — Check only, don't apply
- `/workflow:update --force` — Overwrite local overrides

**Override Detection:**
Files different from previous base version are preserved unless `--force`.

> "Run the workflow-kit installer with update mode. Fetch https://raw.githubusercontent.com/tuti-cli/workflow-kit/main/install.sh and execute. IF --check: pass --check flag (show available update without applying). IF --force: pass --force flag (discard local overrides). Report summary of updated files and preserved overrides."
