# workflow:audit

> Analyze codebase health, dependencies, quality, and security. Produces AUDIT.md and TECH-DEBT.md.

**Usage:**
- `/ww:audit` — standard health check
- `/ww:audit --legacy` — deep legacy analysis for migration
- `/ww:audit --debt-only` — just update TECH-DEBT.md from existing AUDIT.md

**What it does (standard):**
1. Dependency scan (outdated, vulnerabilities)
2. Code quality metrics
3. Test coverage check
4. Security findings
5. Architecture pattern health
6. Writes `.workflow/AUDIT.md`

**What it does (--legacy):**
1. Everything in standard, plus:
2. EOL/abandoned dependency identification
3. Deprecated pattern detection
4. Migration path assessment
5. Full security audit

**What it does (--debt-only):**
1. Reads existing .workflow/AUDIT.md
2. Converts to prioritized TECH-DEBT.md

**Related:**
- `/ww:discover` — onboarding + audit
- `/ww:plan` — plan work from findings

Invoke `codebase-auditor`:
> "Run /ww:audit. Read CLAUDE.md for stack and quality config. IF --legacy: run deep legacy analysis. IF --debt-only: read existing AUDIT.md and convert to TECH-DEBT.md. ELSE: run standard health check. Write .workflow/AUDIT.md. After AUDIT.md, invoke tech-debt-mapper to create .workflow/TECH-DEBT.md."
