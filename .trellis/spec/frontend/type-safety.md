# Type Safety

> Type safety patterns in this project.

---

## Overview

InDraft is written in Swift with strict type safety. The project targets macOS 14+ and uses Swift's native type system, SwiftData model macros, and Swift concurrency.

---

## Type Organization

| Location | Contents |
|----------|----------|
| `Models/` | SwiftData `@Model` classes — `Action`, `Provider`, `HistoryRecord` |
| `Models/Enums/` | Domain enums — `OutputBehavior`, `ProviderMode`, `AppStatus`, `TestStatus` |
| `Services/` | Protocol definitions alongside their implementations |
| `ViewModels/` | ViewModel classes (no separate type files needed) |

### Enums for fixed domains

```swift
enum OutputBehavior: String, Codable, CaseIterable {
    case replace
    case preview
    case clipboard
}

enum ProviderMode: String, Codable {
    case active   // Use the globally active provider
    case fixed    // Use a specific provider
}

enum AppStatus: String {
    case idle
    case processing
    case success
    case error
    case permissionRequired
}

enum TestStatus: String, Codable {
    case untested
    case success
    case failed
}
```

---

## Swift Concurrency

All async work uses structured concurrency (`async/await`), not Combine or callback closures.

```swift
// GOOD
func testConnection() async throws -> TestResult {
    let response = try await apiClient.send(testRequest)
    return TestResult(latency: response.latency, model: response.model)
}

// BAD: Callback-based
func testConnection(completion: @escaping (Result<TestResult, Error>) -> Void) {
    // ...
}
```

### Actor isolation

- ViewModels are `@Observable` classes on `@MainActor` (UI state must be main-thread)
- Services performing I/O are plain classes with `async` methods (structured concurrency handles thread safety)

```swift
@MainActor
@Observable
final class ProviderEditorViewModel {
    var isTestingConnection = false
    var testResult: TestResult?

    func testConnection() async {
        isTestingConnection = true
        defer { isTestingConnection = false }
        do {
            testResult = try await providerService.test(provider)
        } catch {
            testResult = .failure(error)
        }
    }
}
```

---

## Validation

### Input validation at the boundary

Validate user input in ViewModels before passing to services:

```swift
@Observable
final class ProviderEditorViewModel {
    var baseURL: String = ""
    var displayName: String = ""

    var baseURLValidation: ValidationResult {
        guard let url = URL(string: baseURL),
              url.scheme == "https" else {
            return .invalid("Base URL must be a valid HTTPS URL")
        }
        return .valid
    }

    var canSave: Bool {
        !displayName.isEmpty && baseURLValidation == .valid
    }
}
```

### Codable for API contracts

```swift
/// OpenAI-compatible chat completions request
struct ChatCompletionsRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
}

struct ChatMessage: Codable {
    let role: String  // "system" | "user" | "assistant"
    let content: String
}

struct ChatCompletionsResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: ChatMessage
    }
}
```

---

## Forbidden Patterns

| Pattern | Why | Use Instead |
|---------|-----|-------------|
| Force unwrap (`!`) on optionals | Crashes at runtime | `guard let`, `if let`, `??` with sensible default |
| `as! Type` forced cast | Crashes at runtime | `as? Type` with handling |
| `Any` or `AnyObject` for domain types | Loses type information | Concrete types or protocols |
| Stringly-typed keys | Typo-prone, no compiler help | Enums or constants |
| Implicit `@Sendable` closures | Concurrency bugs | Explicit `@Sendable` or structured concurrency |
| `NSObject` subclassing for new code | Unnecessary ObjC baggage | Swift structs/classes unless AppKit interop required |

### Exception: AppKit interop

Some macOS APIs require `NSObject` subclassing (e.g., `NSApplication` delegate, global hotkey registration). This is acceptable only in the `App/` and `Services/` layers, not in Views.
