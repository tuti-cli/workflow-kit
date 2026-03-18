# Testing Rules

> Base layer — testing standards for all stacks.

---

## Coverage Thresholds

| Scope | Minimum |
|-------|---------|
| Overall project | 80% |
| New code in PR | 90% |
| Critical paths | 95% |

### Critical Paths
- Authentication and authorisation
- Data create/update/delete
- Payment processing
- Marked with `// @critical`

---

## Test Naming

Test name must complete "it [does something]":

```php
// Good
it('returns 404 when user not found')
it('creates stripe customer on registration')

// Bad
it('test user')
it('works correctly')
```

---

## Test Structure — Arrange / Act / Assert

```php
it('sends welcome email', function () {
    // Arrange
    Mail::fake();

    // Act
    $user = $this->userService->create($data);

    // Assert
    Mail::assertSent(WelcomeEmail::class);
});
```

---

## No Mocks Policy

- **Never** mock classes you own
- **Always** mock external services (Stripe, Mail, S3)
- Use framework fakes: `Mail::fake()`, `Queue::fake()`

```php
// Never mock your own service
$mock = Mockery::mock(UserService::class);

// Test the real service with fake external
Mail::fake();
$user = $this->userService->create($data);
Mail::assertSent(WelcomeEmail::class);
```

---

## Test Organisation

```
tests/
├── Unit/          # Pure logic, no DB, no HTTP
├── Feature/      # Full stack with database
└── Integration/  # External services
```

- Unit: never touch database
- Feature: use `RefreshDatabase` or transactions

---

## What Must Always Be Tested

1. Happy path
2. Validation failures
3. Edge cases (empty, null, boundary)
4. Exception paths
5. Side effects (emails, jobs, events)
