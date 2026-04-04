# State Management

> How state is managed in this project.

---

## Overview

InDraft uses a layered state architecture:
- **SwiftData** for persistent domain models (Actions, Providers, HistoryRecords)
- **`@Observable` ViewModels** for screen-level UI state and business logic orchestration
- **`@State`** for view-local ephemeral state
- **`@AppStorage`** for lightweight user preferences

No third-party state management libraries (no TCA, no Redux-like patterns).

---

## State Categories

### 1. Persistent Domain State (SwiftData)

All core domain models are SwiftData `@Model` classes stored in a local SQLite database.

| Model | Stored In | Mutated By |
|-------|----------|------------|
| `Action` | SwiftData | `ActionEditorViewModel`, `SettingsViewModel` |
| `Provider` | SwiftData | `ProviderEditorViewModel` |
| `HistoryRecord` | SwiftData | `TransformationService` |

**Access pattern:** Views use `@Query` for read-only lists. ViewModels use `ModelContext` for mutations.

```swift
// In a view — read-only query
struct ActionsSettingsView: View {
    @Query(sort: \Action.sortOrder) private var actions: [Action]
}

// In a ViewModel — mutations
@Observable
final class ActionEditorViewModel {
    private let modelContext: ModelContext

    func save(_ action: Action) throws {
        modelContext.insert(action)
        try modelContext.save()
    }
}
```

### 2. Screen State (ViewModels)

Each major screen gets an `@Observable` ViewModel that owns:
- Loading/error states
- Form validation state
- Derived/computed values
- Async operation orchestration

```swift
@Observable
final class OnboardingViewModel {
    var currentStep: OnboardingStep = .welcome
    var accessibilityGranted = false
    var providerTestResult: TestResult?
    var isTestingConnection = false
}
```

### 3. Ephemeral View State (`@State`)

For UI-only state that doesn't survive navigation:

```swift
@State private var showingDeleteConfirmation = false
@State private var hotkeyInput = ""
@State private var isHovered = false
```

**Rule:** If the state is needed by a child view, lift it to the ViewModel. `@State` stays local.

### 4. User Preferences (`@AppStorage`)

For simple key-value settings persisted in `UserDefaults`:

```swift
@AppStorage("launchAtLogin") private var launchAtLogin = false
@AppStorage("showDockIcon") private var showDockIcon = false
@AppStorage("historyRetentionDays") private var historyRetentionDays = 30
@AppStorage("historyEnabled") private var historyEnabled = true
@AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
```

### 5. Secure State (Keychain)

API keys are **never** stored in SwiftData or UserDefaults. They are stored in macOS Keychain and accessed via `KeychainService`.

```swift
// Provider stores a reference key, not the actual secret
@Model
final class Provider {
    var apiKeyReference: String  // Keychain item identifier
    // ...
}

// KeychainService handles actual storage
class KeychainService {
    func store(apiKey: String, for reference: String) throws
    func retrieve(for reference: String) throws -> String
    func delete(for reference: String) throws
}
```

---

## State Flow

```
User Action (hotkey / UI interaction)
    ↓
ViewModel (orchestrates, validates)
    ↓
Service Layer (business logic, API calls)
    ↓
SwiftData ModelContext (persists changes)
    ↓
@Query / @Observable (UI updates automatically)
```

---

## When to Promote State

| Signal | Action |
|--------|--------|
| Two+ views need the same value | Move to shared ViewModel or SwiftData |
| State must survive navigation | Move to ViewModel or `@AppStorage` |
| State is a secret (API key) | Move to Keychain via `KeychainService` |
| State is derived from domain models | Computed property on ViewModel |

---

## Common Mistakes

- **Storing API keys in `@AppStorage` or SwiftData** — must use Keychain
- **Using `@Query` in ViewModels** — `@Query` is a view property wrapper; use `ModelContext.fetch()` in ViewModels
- **Duplicating SwiftData model state in ViewModel properties** — let `@Query` be the source of truth for lists; ViewModel owns transient state only
- **Creating multiple `ModelContainer` instances** — one container at the app level, inject `ModelContext` where needed
- **Using `@State` for ViewModel instances that should persist** — `@State` for ViewModels is fine at the creation point, but don't re-create them on every navigation
