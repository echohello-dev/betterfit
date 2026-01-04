---
date: 2026-01-04
status: Accepted
---

# 0003: API Mocking Strategy for Testing

## Context

We investigated using MSW (Mock Service Worker) for local development and integration testing. MSW is an industry-standard API mocking library for JavaScript that intercepts network requests at the Service Worker or Node.js level.

**Problem:** BetterFit is a native Swift/iOS project. MSW is JavaScript-only and cannot intercept `URLSession` requests from Swift applications.

**Constraints:**
- Must support unit tests without network dependencies
- Must support local development with real API behavior
- Must enable testing of error scenarios (network failures, 500 errors)
- Should not add unnecessary complexity or dependencies

## Decision

**Do not use MSW.** Instead, use a layered mocking strategy native to Swift:

### 1. Local Development → Local Supabase (already configured)

```bash
mise run supabase:start
mise run supabase:configure
mise run ios:open
```

Provides real PostgreSQL, Auth, and API responses without mocking.

### 2. Unit Tests → Protocol Abstraction (extend existing pattern)

Continue using `PersistenceProtocol` pattern:
- `LocalPersistenceService` for tests (in-memory)
- `SupabasePersistenceService` for production

Extend to other services (Auth, etc.) as needed via dependency injection.

### 3. Integration Tests → URLProtocol (if needed)

For network-level error simulation, use Swift's `URLProtocol`:

```swift
class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    // ... intercepts all URLSession requests
}
```

### 4. UI Tests → Launch Arguments (already in use)

```swift
app.launchArguments = ["UI_TESTING", "DEMO_MODE"]
```

**Guardrails:**
- Never add JavaScript mocking tools to a Swift project
- Keep mock implementations in test targets only
- Prefer protocol abstraction over network-level mocking for unit tests

## Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| **MSW** | JavaScript-only, incompatible with Swift/URLSession |
| **OHHTTPStubs** | Good option, but adds dependency; URLProtocol is built-in |
| **Mocker** | Similar to OHHTTPStubs; prefer built-in solutions first |
| **Charles Proxy / mitmproxy** | External tooling, not suitable for automated tests |

## Consequences

**Positive:**
- No new dependencies for basic mocking needs
- Leverages existing `PersistenceProtocol` pattern
- Local Supabase provides realistic development environment
- URLProtocol is a system-level solution that works with any networking library

**Negative:**
- URLProtocol requires more boilerplate than MSW's declarative handlers
- Must extend protocol abstraction manually to new services

**Follow-up work:**
- Consider adding `AuthServiceProtocol` if auth mocking becomes needed
- Evaluate OHHTTPStubs/Mocker if URLProtocol boilerplate becomes burdensome

## References

- [URLProtocol Apple Documentation](https://developer.apple.com/documentation/foundation/urlprotocol)
- [MSW Documentation](https://mswjs.io/) (for context on what we evaluated)
- [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs) (alternative if needed)
