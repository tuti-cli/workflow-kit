# workflow:arch

> Architecture decision workflow: brainstorm options, challenge proposals, decide and record.

**Usage:**
- `/ww:arch brainstorm <topic>` — explore architecture options
- `/ww:arch challenge <topic>` — stress-test a proposal
- `/ww:arch decide <topic>` — lock in decision and write ADR

**Workflow:**

1. **brainstorm** — Explore options
   - Invoke `architecture-lead`
   - Generate 2-3 options with tradeoffs
   - Write to `.workflow/proposals/[topic].md`

2. **challenge** — Stress-test proposal
   - Invoke `architecture-challenger`
   - Find failure modes, rule conflicts, hidden costs
   - Write to `.workflow/challenges/[topic].md`

3. **decide** — Lock in decision
   - Review challenge findings
   - Choose option and document rationale
   - Invoke `architecture-lead` (recording phase) to:
     - Write ADR to `.workflow/ADRs/NNN-[topic].md`
     - Update `.claude/rules/project/architecture.md`
     - Create follow-up issue if needed

**Related:**
- `/ww:plan` — plan implementation after decision
- `/rules:show` — view architecture rules

Invoke `architecture-lead`:
> "Run /ww:arch. IF brainstorm: invoke architecture-lead to explore 2-3 options with tradeoffs, write proposal. IF challenge: invoke architecture-challenger to stress-test existing proposal. IF decide: invoke architecture-lead (recording phase) to write ADR, update architecture rules, create issue if needed."
