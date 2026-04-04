# Database Guidelines

> SwiftData patterns and conventions for this project.

---

## Overview

InDraft uses **SwiftData** (Apple's native persistence framework, built on Core Data/SQLite) for all local storage. The project targets macOS 14+ which includes SwiftData support.

---

## Models

### Model definition pattern

```swift
import SwiftData

@Model
final class Action {
    var id: UUID
    var name: String
    var prompt: String
    var hotkey: String?              // nil = no hotkey assigned
    var outputBehavior: OutputBehavior
    var providerMode: ProviderMode
    var provider: Provider?          // nil when providerMode == .active
    var modelOverride: String?
    var isEnabled: Bool
    var sortOrder: Int
    var createdAt: Date
    var updatedAt: Date

    init(name: String, prompt: String, outputBehavior: OutputBehavior = .replace) {
        self.id = UUID()
        self.name = name
        self.prompt = prompt
        self.outputBehavior = outputBehavior
        self.providerMode = .active
        self.isEnabled = true
        self.sortOrder = 0
        self.createdAt = .now
        self.updatedAt = .now
    }
}
```

### Rules
- All models are `final class` with `@Model` macro
- Every model has a `UUID` id field
- Timestamps: `createdAt` set in `init`, `updatedAt` set on every mutation
- Optional fields use `?` (not empty string defaults)
- Enum fields use `RawRepresentable` with `String` raw values for readability in the SQLite store

---

## Relationships

```
Action ──(optional)──▶ Provider    (providerMode == .fixed)
HistoryRecord ──(snapshot)──▶ references Action and Provider by ID + name
```

### Key relationship rules from PRD

- `Action.provider` is nullable — nil means "use active provider"
- `HistoryRecord` stores `actionName` and `providerName` as **snapshots** (string copies), not just foreign keys — history remains readable if actions/providers are deleted
- Deleting a Provider nullifies `Action.provider` for referencing actions and switches them to `providerMode = .active`
- Deleting an Action does **not** delete its HistoryRecords
- Exactly one Provider has `isActive = true` at any time (enforced at the service layer, not DB constraint)

### Delete rules

```swift
@Model
final class Provider {
    // When this provider is deleted, nullify the relationship on actions
    @Relationship(inverse: \Action.provider)
    var actions: [Action] = []
    // ...
}
```

---

## ModelContainer Setup

One container, configured at the app level:

```swift
@main
struct InDraftApp: App {
    var body: some Scene {
        MenuBarExtra { /* ... */ }
            .modelContainer(for: [Action.self, Provider.self, HistoryRecord.self])
    }
}
```

**Rules:**
- Never create multiple `ModelContainer` instances
- Pass `ModelContext` to services via init injection
- Views use `@Query` for read-only fetching; services use `ModelContext` for mutations

---

## Query Patterns

### In views (read-only)

```swift
@Query(sort: \Action.sortOrder) private var actions: [Action]
@Query(filter: #Predicate<HistoryRecord> { $0.status == "success" },
       sort: \HistoryRecord.timestamp, order: .reverse)
private var recentHistory: [HistoryRecord]
```

### In services (read-write)

```swift
func fetchActiveProvider(context: ModelContext) throws -> Provider? {
    let descriptor = FetchDescriptor<Provider>(
        predicate: #Predicate { $0.isActive && $0.isEnabled }
    )
    return try context.fetch(descriptor).first
}
```

### Batch operations

```swift
func cleanupOldHistory(olderThan date: Date, context: ModelContext) throws {
    let descriptor = FetchDescriptor<HistoryRecord>(
        predicate: #Predicate { $0.timestamp < date }
    )
    let old = try context.fetch(descriptor)
    for record in old {
        context.delete(record)
    }
    try context.save()
}
```

---

## Migrations

SwiftData handles lightweight migrations automatically (adding fields, removing fields). For complex migrations:

1. Define a `VersionedSchema` for each schema version
2. Create a `SchemaMigrationPlan` with migration stages
3. Pass the migration plan to `ModelContainer`

**For MVP:** Rely on automatic lightweight migration. Add versioned schemas when the data model stabilizes post-MVP.

---

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Model classes | Singular PascalCase | `Action`, `Provider`, `HistoryRecord` |
| Properties | camelCase | `sortOrder`, `apiKeyReference`, `isEnabled` |
| Enum raw values | lowercase string | `"replace"`, `"preview"`, `"clipboard"` |
| Predicate variables | descriptive | `#Predicate { $0.isActive && $0.isEnabled }` |

---

## Common Mistakes

- **Mutating models outside `ModelContext`** — always fetch, mutate, then `context.save()`
- **Using `@Query` in services** — `@Query` is a SwiftUI property wrapper; use `context.fetch()` in services
- **Forgetting `try context.save()`** — SwiftData auto-saves at certain points, but explicit save ensures consistency
- **Storing API keys in model fields** — Provider stores `apiKeyReference` (a Keychain lookup key), never the actual secret
- **Not setting `updatedAt`** — update this timestamp on every mutation
- **Relying on cascade delete for HistoryRecord** — history records must survive action/provider deletion
