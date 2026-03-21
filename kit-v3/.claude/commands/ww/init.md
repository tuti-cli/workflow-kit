# ww:init

> Initialize workflow-kit in a new or existing project.

**Usage:**
- `/ww:init` — interactive initialization
- `/ww:init --owner=org --repo=name` — with explicit GitHub config

## Steps

1. **Check prerequisites**
   - Verify `gh` CLI is installed and authenticated
   - Verify project directory exists

2. **Detect or ask for GitHub config**
   - If `--owner` and `--repo` provided: use them
   - Else if CLAUDE.md exists: extract owner/repo
   - Else: ask user for owner and repo

3. **Detect stack**
   - Read `composer.json` → Laravel, WordPress, PHP
   - Read `package.json` → React, Vue, Nuxt, Next, Node
   - Read `requirements.txt` / `pyproject.toml` → Python
   - Read `wp-config.php` → WordPress
   - Set quality gate commands based on stack

4. **Ask workflow mode**
   ```
   "What's your goal?"
   → Build something new (scratch)
   → Improve existing codebase (issues)
   ```

5. **Download and install workflow-kit**
   - Fetch latest release from tuti-cli/workflow-kit
   - Create `.claude/` structure (agents/, commands/ww/, skills/, rules/)
   - Create `.workflow/` structure (core/, analysis/, decisions/, execution/, meta/)
   - Replace template variables in all files

6. **Set up GitHub labels** (issues mode only)
   - Run `scripts/setup-labels.sh` to create type/priority/status labels

7. **Create or migrate CLAUDE.md**

   **If no CLAUDE.md exists:**
   - Create from `config/CLAUDE.example.md` template
   - Fill in: owner, repo, stack, lint command, test command, mode

   **If CLAUDE.md exists:**
   - Rename existing file to `CLAUDE-OLD.md`
   - Create fresh `CLAUDE.md` from `config/CLAUDE.example.md` template
   - Fill in detected config values (owner, repo, stack, quality commands)
   - Inform user:
     ```
     Existing CLAUDE.md renamed to CLAUDE-OLD.md
     Fresh CLAUDE.md created from v3 template.

     Run /ww:discover to migrate rules from CLAUDE-OLD.md
     Delete CLAUDE-OLD.md manually when done.
     ```

8. **Post-install guidance**
   ```
   Workflow-kit installed.

   Next steps:
   - /ww:discover — analyze project, install recommended skills
   - /ww:describe <file> — create project description from docs
   - /ww:plan — plan your first feature
   ```
