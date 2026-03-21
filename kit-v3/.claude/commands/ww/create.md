# ww:create

> Generate skills, agents, or issues with validation. Enforces three-layer model rules.

**Usage:**
- `/ww:create skill <name>` — create a new skill
- `/ww:create skill <name> --from <voltagent-name>` — from VoltAgent source
- `/ww:create skill <name> --global` — install to ~/.claude/skills/
- `/ww:create agent <name>` — create a new agent
- `/ww:create agent <name> --from <voltagent-name>` — from VoltAgent source
- `/ww:create agent <name> --global` — install to ~/.claude/agents/
- `/ww:create issue` — create GitHub issue from context
- `/ww:create issue --plan` — create from PLAN.md
- `/ww:create issue --adr` — create from latest ADR
- `/ww:create issue --patch <file>` — create from patch
- `/ww:create issue --execute` — create and immediately run `/ww:do N`

## Create Skill

1. **Validate type** (grill)
   ```
   "Does this need to think?"
   → No = pipeline step. REJECT: "This belongs in command logic, not a skill."
   → Yes, depends on context = agent. REDIRECT: "This sounds like an agent. Use /ww:create agent <name>."
   → Yes, always same way = skill. PROCEED.
   ```

2. **Additional validation**
   ```
   "Does this change how things are done, or does it do a thing?"
   → Does a thing = agent. REDIRECT.
   → Changes behavior = skill. PROCEED.
   ```

3. **Load source** (if --from)
   - Fetch VoltAgent agent from: `https://raw.githubusercontent.com/VoltAgent/awesome-claude-code-subagents/main/categories/{category}/{name}.md`
   - Use as starting point for content

4. **Determine skill category**
   - Stack-specific (laravel, vue, react) → `skills/stack/`
   - Workflow behavior → `skills/workflow/`
   - General tool/pattern → `skills/tools/`

5. **Generate skill content**
   - Rewrite as "how to think" not "what to do"
   - Write proper frontmatter:
     ```yaml
     ---
     name: <name>
     description: "<precise trigger description>"
     user-invocable: false  # for background knowledge
     ---
     ```
   - Description must be specific enough for correct auto-loading

6. **Validate**
   - Not duplicating existing skill
   - Not overlapping with an agent
   - Description is precise (not vague like "best practices")

7. **Show draft for approval**
   ```
   Skill draft:
   [show full content]

   Write to .claude/skills/{category}/{name}/SKILL.md?
   → Approve | Edit | Cancel
   ```

8. **Write file**

## Create Agent

1. **Validate type** (grill)
   ```
   "Does this need to think?"
   → No = pipeline step. REJECT.
   → Yes, always same way = skill. REDIRECT to /ww:create skill.
   → Yes, depends on context = agent. PROCEED.

   "Does this do a thing and return a result?"
   → No = not an agent. REJECT.
   → Yes = agent. PROCEED.
   ```

2. **Load source** (if --from)
   - Fetch VoltAgent agent as starting point

3. **Generate agent content**
   - Rewrite as focused job with clear deliverable
   - Write proper frontmatter:
     ```yaml
     ---
     name: <name>
     description: "<what job it does>"
     model: haiku | sonnet | opus
     tools: [minimum needed]
     skills: [skills this agent needs loaded]
     ---
     ```
   - Must have clear input/output contract

4. **Validate**
   - Has clear deliverable (what does it return?)
   - Not duplicating a skill
   - Not a disguised pipeline step
   - Skills listed in frontmatter exist

5. **Show draft for approval**

6. **Write file** to `.claude/agents/{name}.md`

## Create Issue

1. **Determine source**
   - If `--plan`: read `.workflow/core/PLAN.md`
   - If `--adr`: read latest `.workflow/decisions/ADRs/*.md`
   - If `--patch <file>`: read specified patch file
   - If no flag: determine from recent work context

2. **Format issue body**
   ```markdown
   ## Summary
   [What needs to be done]

   ## Context
   [Why this matters]

   ## Acceptance Criteria
   - [ ] Criterion 1
   - [ ] Criterion 2

   ## Technical Notes
   [Stack details, constraints]

   ## Definition of Done
   - [ ] Code written and tested
   - [ ] Docs updated
   - [ ] Issue closed with summary
   ```

3. **Apply labels**
   - Detect type from content: `type:feature`, `type:bug`, etc.
   - Set priority
   - Set `status:ready`

4. **Show for approval**
   ```
   Create this issue?
   → Create | Edit | Cancel
   ```

5. **Create via GitHub**
   - `gh issue create --repo {owner}/{repo} --title "..." --body "..." --label "..."`
   - Report issue number

6. **If --execute:** immediately run `/ww:do N` with new issue number
