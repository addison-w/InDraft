# Directory Structure

> How service/data layer code is organized in this project.

---

## Overview

InDraft's "backend" is entirely local — there is no server. The service layer handles SwiftData persistence, Keychain access, Accessibility API interaction, AI provider networking, and global hotkey registration. All code lives within the `InDraft/` target.

---

## Directory Layout

```
InDraft/
├── Models/
│   ├── Action.swift               # SwiftData @Model — transformation action
│   ├── Provider.swift             # SwiftData @Model — AI provider config
│   ├── HistoryRecord.swift        # SwiftData @Model — transformation log entry
│   └── Enums/
│       ├── OutputBehavior.swift    # replace | preview | clipboard
│       ├── ProviderMode.swift     # active | fixed
│       ├── AppStatus.swift        # idle | processing | success | error | permissionRequired
│       └── TestStatus.swift       # untested | success | failed
├── Services/
│   ├── TransformationService.swift    # Orchestrates capture → API → replace flow
│   ├── TextCaptureService.swift       # Accessibility API text reading + clipboard fallback
│   ├── TextReplacementService.swift   # Accessibility API text writing + clipboard fallback
│   ├── AIProviderService.swift        # OpenAI-compatible chat completions client
│   ├── KeychainService.swift          # macOS Keychain CRUD for API keys
│   ├── HotkeyService.swift            # Global hotkey registration (Carbon/CGEvent)
│   ├── PermissionService.swift        # Accessibility permission checking
│   ├── HistoryService.swift           # History CRUD, retention cleanup
│   └── ClipboardService.swift         # NSPasteboard save/restore operations
├── Utilities/
│   ├── Logger+Extensions.swift        # os.Logger category definitions
│   └── KeychainError.swift            # Keychain-specific error types
├── App/
│   ├── InDraftApp.swift               # @main entry, MenuBarExtra scene
│   └── AppDelegate.swift              # NSApplicationDelegate lifecycle
├── Views/          # (see frontend/ guidelines)
├── ViewModels/     # (see frontend/ guidelines)
└── Components/     # (see frontend/ guidelines)
```

---

## Module Organization

### Services are single-responsibility

Each service owns one capability. The `TransformationService` orchestrates them:

```
TransformationService (orchestrator)
├── TextCaptureService      — reads selected text
├── AIProviderService       — sends text to AI, gets result
├── TextReplacementService  — writes result back
├── HistoryService          — logs the transformation
├── ClipboardService        — clipboard save/restore
└── KeychainService         — retrieves API key for provider
```

### New services

When adding a new capability:
1. Create a new `*Service.swift` in `Services/`
2. Define a protocol if the service will be mocked in tests
3. Inject it via init, not singletons

### New models

When adding a new data entity:
1. Create `ModelName.swift` in `Models/`
2. If it has fixed-domain fields, create an enum in `Models/Enums/`
3. Register the model in the `ModelContainer` configuration in `InDraftApp.swift`

---

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| SwiftData models | `PascalCase`, singular noun | `Action`, `Provider`, `HistoryRecord` |
| Services | `PascalCase` + `Service` suffix | `KeychainService`, `AIProviderService` |
| Enums | `PascalCase`, cases are `camelCase` | `OutputBehavior.clipboardOnly` |
| Protocols | `PascalCase` + descriptive name | `TextCapturing`, `AIProviding` |
| Error types | `PascalCase` + `Error` suffix | `KeychainError`, `TransformationError` |
| Logger categories | Static `os.Logger` with subsystem + category | `Logger(subsystem: "com.indraft", category: "keychain")` |

---

## Anti-Patterns

- **Don't** create singleton services with `static let shared` — use dependency injection via init
- **Don't** put business logic in SwiftData `@Model` classes — models are data containers; logic goes in services
- **Don't** access `NSPasteboard` directly from views or ViewModels — use `ClipboardService`
- **Don't** mix Accessibility API calls with UI code — isolate in `TextCaptureService` / `TextReplacementService`
- **Don't** store API keys anywhere except Keychain — not in SwiftData, not in UserDefaults, not in files
