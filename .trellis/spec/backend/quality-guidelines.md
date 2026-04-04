# Quality Guidelines

> Code quality standards for the service/data layer.

---

## Overview

Quality standards for InDraft's service layer, data models, and system integrations. These complement the frontend quality guidelines.

---

## Forbidden Patterns

| Pattern | Why | Fix |
|---------|-----|-----|
| `static let shared` singletons | Untestable, hidden dependencies | Inject dependencies via init |
| `print()` | No structure, no privacy, no filtering | `os.Logger` |
| Storing secrets in UserDefaults/SwiftData | Security risk | `KeychainService` |
| `DispatchQueue` / GCD | Mixing concurrency models | `async/await`, structured concurrency |
| Bare `URLSession.shared.data(for:)` in ViewModels | Wrong layer | Call through `AIProviderService` |
| `try!` or `try?` that silently swallows errors | Lost diagnostics | Explicit `do/catch` with logging |
| Direct `NSPasteboard` access outside `ClipboardService` | Scattered clipboard state | Route through `ClipboardService` |
| `Thread.sleep()` or `usleep()` | Blocks threads | `Task.sleep(for:)` |
| Hard-coded URLs or API paths | Fragile | Constants or Provider configuration |

---

## Required Patterns

### Dependency injection

```swift
// GOOD: Injectable, testable
final class TransformationService {
    private let captureService: TextCaptureService
    private let providerService: AIProviderService
    private let replacementService: TextReplacementService

    init(captureService: TextCaptureService,
         providerService: AIProviderService,
         replacementService: TextReplacementService) {
        self.captureService = captureService
        self.providerService = providerService
        self.replacementService = replacementService
    }
}
```

### Protocol-based abstractions for testability

Define protocols for services that interact with system APIs:

```swift
protocol TextCapturing {
    func captureSelectedText() async throws -> String
}

protocol AIProviding {
    func transform(text: String, prompt: String, provider: Provider) async throws -> String
    func testConnection(provider: Provider) async throws -> TestResult
}
```

Real implementations use Accessibility API, Keychain, URLSession. Test mocks return predictable values.

### Explicit error handling

```swift
// GOOD: Specific catch, logged, surfaced
do {
    let result = try await providerService.transform(text: text, prompt: prompt, provider: provider)
    Logger.transformation.info("transform_complete: latencyMs=\(latency)")
    return result
} catch let error as ProviderError {
    Logger.transformation.error("transform_failed: stage=api error=\(error)")
    throw TransformationError.providerError(error)
}
```

---

## Concurrency Rules

- All async work uses Swift structured concurrency (`async/await`)
- Services are plain classes (not actors, unless they manage mutable shared state)
- `@MainActor` only on ViewModels and UI-touching code
- Long-running operations (API calls, file I/O) must be `async` — never block the main thread
- Use `Task.sleep(for:)` instead of `Thread.sleep` when timing is needed (e.g., clipboard restore delay)
- Use `withTaskGroup` for parallel independent operations (e.g., testing multiple providers)

---

## Security Rules

| Rule | Detail |
|------|--------|
| API keys in Keychain only | Never in SwiftData, UserDefaults, or source code |
| HTTPS only | Reject `http://` base URLs at validation time |
| No telemetry or analytics | No network requests except to user's configured provider |
| Clipboard restore | Original clipboard must be restored within 30 seconds after clipboard-based operations |
| Minimal data sent | Only selected text + action prompt sent to provider |

---

## Testing Requirements

### Unit tests for all services

| Service | What to Test |
|---------|-------------|
| `AIProviderService` | Response parsing, error mapping (401 → authFailed, 404 → modelNotFound, etc.) |
| `KeychainService` | Store/retrieve/delete cycle, duplicate handling, not-found handling |
| `HistoryService` | CRUD, retention cleanup, search filtering |
| `TransformationService` | Orchestration flow, fallback chain (mock capture/replace services) |
| `HotkeyService` | Registration, conflict detection, deregistration |

### Mock strategy

- Mock protocols (`TextCapturing`, `AIProviding`) for unit tests
- Use in-memory `ModelContainer` for SwiftData tests: `ModelConfiguration(isStoredInMemoryOnly: true)`
- Never hit real APIs in unit tests — mock `URLProtocol` or use protocol abstraction

### Integration tests

- Keychain operations against the real Keychain (test target Keychain access group)
- SwiftData operations with in-memory store

---

## Code Review Checklist

- [ ] No singletons — dependencies injected via init
- [ ] No secrets in source code or non-Keychain storage
- [ ] All errors caught, logged, and surfaced (no silent `try?`)
- [ ] Async code uses structured concurrency (no GCD, no Combine for new code)
- [ ] Services have protocols for testability
- [ ] Logger used with appropriate privacy annotations
- [ ] Base URLs validated as HTTPS
- [ ] Clipboard state restored within documented timeframes
