# Architecture Rules

> Base layer — structural patterns for all projects.

---

## Layered Architecture

### Controllers
- **Never** put business logic in controllers
- Allowed: validate input, call one service, return response
- Max method length: 20 lines
- **Never** query database directly

### Services
- Business logic in service classes
- One responsibility per service
- Must be injectable
- **Never** make static

### Data Access (scopes → queries → actions)

Priority order:

1. **Model scopes** — for reusable query logic
   ```php
   // Preferred — scopes are on the model
   User::active()->with('posts')->get();
   ```

2. **Query objects** (`app/Queries/`) — for complex queries
   ```php
   // For complex queries that don't fit in a scope
   app(UserQuery::class)->filterByStatus($status)->paginate();
   ```

3. **Action classes** (`app/Actions/`) — for complex operations
   ```php
   // For complex multi-step operations
   app(CreateUserAction::class)->execute($data);
   ```

### Models
- Hold data shape and relationships only
- **Never** add business logic
- Scopes are OK for reusable query conditions

---

## Dependency Direction

```
Controller → Service → Action/Query/Scope → Model
```

Services know about actions/queries/scopes. Lower layers never know upper.

---

## Boundaries

- **Never** import framework code into domain logic
- Framework integration at outer layer (controllers)
- Domain must be testable without framework
