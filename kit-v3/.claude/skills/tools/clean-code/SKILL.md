---
name: clean-code
description: "Clean code instincts for writing maintainable, readable code. Apply when implementing features, refactoring, or reviewing code in any stack."
user-invocable: false
---

# Clean Code

## Naming
- Names reveal intent — no abbreviations unless universally understood
- Boolean names start with is/has/can/should
- Functions describe what they do, not how
- Collections use plural nouns

## Functions
- Do one thing
- Max 3 parameters — use object/DTO if more
- No side effects hidden in getters
- Early returns over nested conditionals

## Structure
- Vertical: related code stays together
- Horizontal: max 100 characters per line
- Group by feature, not by type

## Complexity
- No nested ternaries
- Max 2 levels of nesting — extract method if deeper
- Prefer guard clauses over else blocks
- Replace complex conditionals with named methods

## Dependencies
- Depend on abstractions, not concretions
- Inject dependencies, don't create them
- Framework code stays at the boundary

## Deletion
- Dead code gets deleted, not commented out
- Unused imports get removed
- Unused variables get removed
