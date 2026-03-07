# workflow:update

> Pull latest updates from workflow-kit base repository.

**Usage:**
- `/workflow:update` — Check and apply updates
- `/workflow:update --check` — Check only, don't apply
- `/workflow:update --force` — Overwrite local overrides

**What it does:**
1. Reads .workflow/.base-version for current version
2. Fetches latest release info from GitHub
3. Compares versions
4. If update available:
   - Downloads new version tarball
   - For each file:
     - New file → Copy
     - Identical to old base → Update
     - Local override detected → Preserve (unless --force)
   - Updates .workflow/.base-version
5. Reports summary of changes

**Override Detection:**
Files are compared to previous base version:
- Identical → Safe to update
- Different → Override preserved (unless --force)

**Example Output:**
```
workflow-kit v1.1.0 available (current: v1.0.0)

Changes:
- master-orchestrator.md: New "Smart Retry Logic" section
- issue-executor.md: Fixed label validation

Your overrides (preserved):
- master-orchestrator.md (modified)

Updated 8 files, 1 override preserved.
```

**Options:**
- `--check` — Show what would update without applying
- `--force` — Discard local overrides, use base versions

**Requirements:**
- .workflow/.base-version file must exist (run /workflow:init first)
- curl or wget for downloading
- Internet connection

Invoke `issue-executor` for context if needed.
