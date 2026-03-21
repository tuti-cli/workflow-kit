# ww:describe

> Transform raw client/project documents into a structured project description. Grills requirements before accepting.

**Usage:**
- `/ww:describe <file>` — from a discovery document
- `/ww:describe --from-issue N` — from a GitHub issue

## Steps

1. **Read source document**
   - If file: read the provided document
   - If `--from-issue N`: fetch issue from GitHub via `gh issue view N --json title,body`

2. **Extract initial understanding**
   - List all features mentioned
   - Identify architecture patterns described
   - Note constraints, requirements, integrations
   - Flag anything vague or contradictory

3. **Grill the requirements** (uses grill-me skill)

   **Phase 1 — Clarify:**
   - One question at a time about unclear requirements
   - "What happens when X?"
   - "Where does Y data come from?"
   - Fill gaps in the original document

   **Phase 2 — Challenge:**
   - "This assumes X — what guarantees that?"
   - "These two features contradict — which wins?"
   - "This scope seems too large for the timeline — what's the MVP?"

   **Phase 3 — Ground in reality:**
   - "What's the user flow for this?"
   - "What happens at 10x users?"
   - "What's the rollback if this fails?"

4. **Produce PROJECT.md**

   Write to `.workflow/core/PROJECT.md`:

   ```markdown
   # Project: [Name]

   ## Summary
   [One paragraph description]

   ## Features
   ### [Feature 1]
   - Description: ...
   - Acceptance criteria: ...
   - Priority: critical / high / medium / low

   ### [Feature 2]
   ...

   ## Architecture
   - Pattern: [monolith / microservices / etc.]
   - Key decisions: ...

   ## Constraints
   - ...

   ## Out of Scope
   - ...

   ## Open Questions
   - ...
   ```

5. **Present for approval**
   ```
   PROJECT.md created. Review and approve?
   → Approve | Edit | Re-grill specific section
   ```
