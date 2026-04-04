# Error Handling

> How errors are handled in this project.

---

## Overview

InDraft uses Swift's native error handling (`throw`/`catch`) with domain-specific error enums. Errors propagate up from services to ViewModels, which translate them into user-facing messages. The user should always understand what went wrong and what to do about it.

---

## Error Types

### Domain error enums

Each service layer defines its own error enum:

```swift
enum TransformationError: LocalizedError {
    case noTextSelected
    case captureFailedAccessibility
    case captureFailedClipboard
    case replacementFailed(underlyingError: Error)
    case providerError(ProviderError)
    case noActiveProvider

    var errorDescription: String? {
        switch self {
        case .noTextSelected:
            return String(localized: "No text selected")
        case .noActiveProvider:
            return String(localized: "No active provider — configure one in Settings > Providers")
        // ...
        }
    }
}

enum ProviderError: LocalizedError {
    case authenticationFailed
    case unreachable(url: String)
    case modelNotFound(model: String)
    case timeout
    case unexpectedResponse
    case rateLimited

    var errorDescription: String? { /* user-friendly messages */ }
    var recoverySuggestion: String? { /* actionable guidance */ }
}

enum KeychainError: LocalizedError {
    case itemNotFound
    case duplicateItem
    case unexpectedStatus(OSStatus)

    var errorDescription: String? { /* ... */ }
}
```

### Rules
- All error enums conform to `LocalizedError`
- Every case has a user-friendly `errorDescription`
- Network/provider errors include `recoverySuggestion` with actionable advice
- Wrap underlying system errors rather than re-throwing raw `NSError` or `OSStatus`

---

## Error Propagation

```
Service throws domain error
    ↓
ViewModel catches, maps to UI state
    ↓
View displays via toast/alert/inline message
```

### In services — throw specific errors

```swift
func testConnection(provider: Provider) async throws -> TestResult {
    let apiKey = try keychainService.retrieve(for: provider.apiKeyReference)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
        throw ProviderError.unexpectedResponse
    }

    switch httpResponse.statusCode {
    case 200: return try parseTestResult(data)
    case 401: throw ProviderError.authenticationFailed
    case 404: throw ProviderError.modelNotFound(model: provider.defaultModel)
    case 429: throw ProviderError.rateLimited
    default:  throw ProviderError.unexpectedResponse
    }
}
```

### In ViewModels — catch and present

```swift
@MainActor
@Observable
final class ProviderEditorViewModel {
    var testResult: TestResult?
    var errorMessage: String?

    func testConnection() async {
        errorMessage = nil
        do {
            testResult = try await providerService.testConnection(provider: provider)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### In views — display

```swift
if let errorMessage = viewModel.errorMessage {
    Text(errorMessage)
        .foregroundStyle(Color.error)
        .font(.caption)
}
```

---

## Transformation Error Flow (Critical Path)

The hotkey → transform → replace pipeline has specific fallback behavior defined in the PRD:

| Failure Point | Behavior |
|--------------|----------|
| No text selected | Toast: "No text selected" — no API call |
| Accessibility capture fails | Auto-fallback to clipboard capture |
| Both capture methods fail | Toast: "Could not read selected text" — abort |
| Provider API fails | Toast with specific error — log to history with `status: .error` |
| Accessibility replacement fails | Auto-fallback to clipboard replacement |
| Both replacement methods fail | Copy result to clipboard, toast: "Result copied to clipboard — paste manually" |

**Key rule:** Failed transformations are **always** logged to `HistoryRecord` with `status: .error` and the specific `errorCode` / `errorMessage`.

---

## Fallback Chain Pattern

```swift
func captureSelectedText() async throws -> String {
    // Try Accessibility API first
    if let text = try? accessibilityCapture() {
        return text
    }

    // Fallback to clipboard-based capture
    if let text = try? clipboardCapture() {
        return text
    }

    // Both failed
    throw TransformationError.captureFailedClipboard
}
```

---

## Common Mistakes

- **Catching all errors with `catch { }` silently** — always log or surface the error
- **Throwing raw `String` or generic `Error`** — use typed enum cases
- **Showing technical error messages to users** — translate to `LocalizedError` with `errorDescription`
- **Not logging failed transformations** — every attempt (success or failure) must be in history
- **Letting clipboard fallback fail silently** — if the fallback also fails, the user must be notified
- **Forgetting `recoverySuggestion`** — provider errors should tell the user what to fix (e.g., "check your API key in Settings > Providers")
