# Testing Rules

> Base layer — testing standards for all stacks.
> Auto-populated by `project-analyst` during `/ww:init` or `/ww:discover`.

---

## Coverage Thresholds

| Scope | Minimum |
|-------|---------|
| Overall project | 80% |
| New code in PR | 90% |
| Critical paths | 95% |

---

## Test Naming

Test name must complete "it [does something]":

```
// Good
it('returns 404 when user not found')
it('creates customer on registration')

// Bad
it('test user')
it('works correctly')
```

---

## Test Structure — Arrange / Act / Assert

```
// Arrange — set up state
// Act     — call the thing
// Assert  — verify the outcome
```

---

## No Mocks Policy

- **Never** mock classes you own
- **Always** mock external services (mail, payments, storage)

---

## Test Organisation

```
tests/
├── Unit/         # Pure logic, no DB, no HTTP
├── Feature/      # Full stack with database
└── Integration/  # External services
```

---

## What Must Always Be Tested

1. Happy path
2. Validation failures
3. Edge cases (empty, null, boundary)
4. Exception paths
5. Side effects (emails, jobs, events)
