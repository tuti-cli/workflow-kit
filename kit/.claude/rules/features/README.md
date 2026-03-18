# Feature Rules

> Subsystem-specific rules. Highest priority — override base and project.

---

## Adding Rules

```bash
/rules:add features/auth "Only use sanctum guards on API routes"
/rules:add features/payments "Always pass idempotency_key to Stripe"
```

---

## Priority

```
features/*.md      ← wins on conflict
project/*.md
base/*.md          ← baseline
```

---

## Loading

Feature rules load selectively based on task context — only relevant subsystems are loaded to keep context lean.
