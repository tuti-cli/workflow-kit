# ww:update

> Pull latest updates from workflow-kit repository.

**Usage:**
- `/ww:update` — check and apply updates
- `/ww:update --check` — check only, don't apply
- `/ww:update --force` — overwrite all files including modified ones

## Steps

1. **Check current version**
   - Read CLAUDE.md for current workflow-kit version

2. **Fetch latest version**
   - Check tuti-cli/workflow-kit for latest release

3. **Compare**
   - If up to date: report and stop
   - If update available: show changelog summary

4. **If --check:** stop here, show available update

5. **Apply update**
   - Download latest release
   - Replace template variables with project values
   - Update commands, skills, rules base layer
   - Preserve: rules/project/, rules/features/, custom skills

6. **If --force:** overwrite all files regardless of local changes

7. **Update CLAUDE.md**
   - Update version number in Workflow section

8. **Report**
   ```
   Updated from v1.0.0 to v1.1.0
   Files updated: N
   Files preserved (custom): N
   ```
