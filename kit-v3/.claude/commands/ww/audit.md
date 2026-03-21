# ww:audit

> Analyze codebase health, dependencies, quality, and security.

**Usage:**
- `/ww:audit` — standard health check
- `/ww:audit --legacy` — deep legacy analysis for migration planning
- `/ww:audit --debt-only` — update TECH-DEBT.md from existing AUDIT.md

## Standard Mode

1. **Dependency scan**
   - Check for outdated packages
   - Check for known vulnerabilities
   - List abandoned/unmaintained dependencies

2. **Code quality**
   - Run lint and report issues
   - Check file sizes (flag files over 300 lines)
   - Detect code duplication patterns

3. **Test coverage**
   - Run test suite with coverage
   - Report coverage percentages
   - Flag uncovered critical paths

4. **Security findings**
   - Check for hardcoded secrets
   - Check for SQL injection patterns
   - Check for XSS vulnerabilities
   - Check dependency vulnerabilities

5. **Write report**
   - Write `.workflow/analysis/AUDIT.md`
   - Write `.workflow/analysis/TECH-DEBT.md` with prioritized items

## Legacy Mode (--legacy)

Everything in standard, plus:

1. **EOL detection**
   - Identify end-of-life dependencies
   - Flag deprecated language features
   - Detect abandoned packages

2. **Migration assessment**
   - Identify upgrade paths for major dependencies
   - Estimate migration complexity per dependency
   - Flag breaking changes

3. **Pattern detection**
   - Find deprecated coding patterns
   - Identify anti-patterns specific to stack
   - List modernization opportunities

## Debt Only Mode (--debt-only)

1. Read existing `.workflow/analysis/AUDIT.md`
2. Convert findings to prioritized `.workflow/analysis/TECH-DEBT.md`
3. Group by: critical / high / medium / low
