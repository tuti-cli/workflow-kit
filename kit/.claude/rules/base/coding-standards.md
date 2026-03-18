# Coding Standards

> Base layer — applies to every project regardless of stack.

---

## PHP Standards

### Types
- **Always** use strict types: `declare(strict_types=1);`
- **Always** add explicit return types
- **Always** add property types — never untyped properties
- **Never** use `mixed` unless unavoidable

### Classes
- **Always** declare classes `final` unless inheritance intended
- **Never** use `abstract` classes — prefer interfaces
- **Always** use constructor property promotion for DTOs

### Dependency Injection
- **Always** inject via constructor
- **Never** use `app()`, `resolve()`, or `Container::make()`
- **Never** use `new ClassName()` inside methods

### Arrays
- **Always** use `Arr::` helpers in Laravel:
  - `Arr::get()` not `$array['key'] ?? null`
  - `Arr::has()` not `isset()`
  - `Arr::first()` not `reset()`

### Naming
- **Classes:** PascalCase — `UserAuthService`
- **Methods:** camelCase — `getUserById()`
- **Variables:** camelCase — `$userId`
- **Constants:** SCREAMING_SNAKE — `MAX_RETRY`
- **Interfaces:** `XxxInterface` suffix
- **Enums:** `XxxEnum` suffix

---

## JavaScript / TypeScript Standards

### Types
- **Always** use TypeScript
- **Never** use `any` — use `unknown`
- **Always** define return types

### Imports
- **Always** use named imports
- **Never** use barrel files in large modules

### Variables
- **Always** use `const`
- **Never** use `var`

---

## Universal Standards

### Comments
- **Never** comment what code does
- **Always** comment why — non-obvious decisions
- Mark critical paths with `// @critical`

### Error Handling
- **Never** silently swallow exceptions
- **Never** use empty catch blocks

### File Organisation
- One class/interface/enum per file
- File name matches class name
- Keep files under 300 lines
