# Observable & Property Wrapper Guidelines

> How reactive state and observation patterns are used in this project.

---

## Overview

This project uses Swift's **Observation framework** (`@Observable`) introduced in macOS 14, not the legacy `ObservableObject`/`@Published` pattern. This file covers property wrappers, observation patterns, and reusable state logic — the SwiftUI equivalent of "hooks."

---

## Observation Framework (Primary Pattern)

### ViewModels use `@Observable`

```swift
@Observable
final class MenuBarViewModel {
    var appStatus: AppStatus = .idle
    var activeProvider: Provider?
    var recentActions: [Action] = []

    // Computed properties are automatically tracked
    var statusIcon: String {
        appStatus.iconName
    }

    // Dependencies injected via init
    private let transformationService: TransformationService

    init(transformationService: TransformationService) {
        self.transformationService = transformationService
    }
}
```

### Views consume with `@Bindable` or direct reference

```swift
struct MenuBarDropdownView: View {
    // For read-write bindings:
    @Bindable var viewModel: MenuBarViewModel

    // For read-only:
    var viewModel: MenuBarViewModel

    var body: some View {
        // Automatically re-renders when accessed properties change
        Text(viewModel.statusIcon)
    }
}
```

---

## Property Wrapper Usage

| Wrapper | When to Use | Scope |
|---------|------------|-------|
| `@State` | View-local ephemeral state (sheet visible, text field value) | Single view |
| `@Bindable` | Two-way binding to `@Observable` object properties | Parent → child |
| `@Environment` | System values or app-wide singletons | Injected from ancestor |
| `@AppStorage` | UserDefaults-backed preferences | App-wide persistent |
| `@Query` | SwiftData model fetching in views | Database |
| `@FocusState` | Keyboard focus tracking | View hierarchy |

---

## Forbidden Patterns

| Pattern | Why | Use Instead |
|---------|-----|-------------|
| `ObservableObject` + `@Published` | Legacy pattern, worse performance | `@Observable` |
| `@StateObject` | Legacy companion to `ObservableObject` | `@State` with `@Observable` class |
| `@ObservedObject` | Legacy companion to `ObservableObject` | Direct reference or `@Bindable` |
| `@EnvironmentObject` | Legacy, type-unsafe | `@Environment` with key |
| Combine `sink`/`assign` in ViewModels | Unnecessary with Observation framework | Computed properties, `async/await` |

---

## Reusable State Logic

For reusable stateful logic (the "custom hook" pattern), create small `@Observable` classes:

```swift
/// Reusable countdown timer logic
@Observable
final class CountdownTimer {
    var remaining: TimeInterval = 0
    var isRunning: Bool = false

    func start(seconds: TimeInterval) {
        remaining = seconds
        isRunning = true
        // ...
    }
}

// Usage in a view:
struct ToastView: View {
    @State private var timer = CountdownTimer()
    // ...
}
```

For simpler cases, use a plain function that returns a `Binding`:

```swift
// NOT a class — just a utility for creating bindings
extension Binding {
    static func throttled(_ source: Binding<String>, interval: TimeInterval) -> Binding<String> {
        // ...
    }
}
```

---

## Async Patterns in ViewModels

```swift
@Observable
final class HistoryViewModel {
    var records: [HistoryRecord] = []
    var isLoading = false
    var searchText = ""

    func loadHistory() async {
        isLoading = true
        defer { isLoading = false }
        records = await historyService.fetchRecords(filter: searchText)
    }
}
```

Views trigger async work with `.task` or button actions:

```swift
struct HistoryWindowView: View {
    @Bindable var viewModel: HistoryViewModel

    var body: some View {
        List(viewModel.records) { record in
            HistoryRowView(record: record)
        }
        .task { await viewModel.loadHistory() }
        .onChange(of: viewModel.searchText) {
            Task { await viewModel.loadHistory() }
        }
    }
}
```

---

## Common Mistakes

- **Using `@State` for a class** — `@State` with a reference type doesn't observe property changes. Use `@State` only for value types or `@Observable` classes.
- **Creating ViewModels inside `body`** — instantiate in `@State` or inject from parent, never recreate per render
- **Using Combine publishers for UI state** — the Observation framework handles this natively
- **Forgetting `@Bindable`** — if you need `$viewModel.property` for a TextField binding, the viewModel parameter must be `@Bindable`
