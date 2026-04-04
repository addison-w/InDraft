# InDraft macOS App — Build Design Spec

**Date:** 2026-04-03
**Approach:** Bottom-Up (Models → Services → UI)
**Method:** TDD — tests first, then implementation
**Platform:** macOS 14+, SwiftUI, SwiftData

---

## 1. Overall Architecture

```
InDraft/
├── App/
│   ├── InDraftApp.swift              # @main, MenuBarExtra scene, ModelContainer
│   └── AppDelegate.swift             # NSApplicationDelegate lifecycle
├── Models/
│   ├── Action.swift                  # SwiftData @Model
│   ├── Provider.swift                # SwiftData @Model
│   ├── HistoryRecord.swift           # SwiftData @Model
│   └── Enums/
│       ├── OutputBehavior.swift      # replace | preview | clipboard
│       ├── ProviderMode.swift        # active | fixed
│       ├── AppStatus.swift           # idle | processing | success | error | permissionRequired
│       ├── TestStatus.swift          # untested | success | failed
│       └── TransformationStatus.swift # success | error
├── Services/
│   ├── TransformationService.swift   # Orchestrator
│   ├── TextCaptureService.swift      # AX API + clipboard fallback
│   ├── TextReplacementService.swift  # AX API + clipboard fallback
│   ├── AIProviderService.swift       # OpenAI-compatible client
│   ├── KeychainService.swift         # macOS Keychain CRUD
│   ├── HotkeyService.swift           # Global hotkey registration
│   ├── PermissionService.swift       # Accessibility permission check
│   ├── HistoryService.swift          # History CRUD + retention
│   └── ClipboardService.swift        # NSPasteboard save/restore
├── ViewModels/
│   ├── MenuBarViewModel.swift
│   ├── OnboardingViewModel.swift
│   ├── SettingsViewModel.swift
│   ├── ActionEditorViewModel.swift
│   ├── ProviderEditorViewModel.swift
│   └── HistoryViewModel.swift
├── Views/
│   ├── MenuBar/
│   │   ├── MenuBarDropdownView.swift
│   │   └── MenuBarIconView.swift
│   ├── Onboarding/
│   │   ├── WelcomeView.swift
│   │   ├── AccessibilityPermissionView.swift
│   │   ├── AddProviderView.swift
│   │   ├── TestConnectionView.swift
│   │   ├── DefaultActionsView.swift
│   │   ├── SampleTransformationView.swift
│   │   └── OnboardingCompleteView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── GeneralSettingsView.swift
│   │   ├── ActionsSettingsView.swift
│   │   ├── ActionEditorView.swift
│   │   ├── ProvidersSettingsView.swift
│   │   ├── ProviderEditorView.swift
│   │   ├── HistorySettingsView.swift
│   │   └── DiagnosticsSettingsView.swift
│   ├── History/
│   │   └── HistoryWindowView.swift
│   ├── Preview/
│   │   └── PreviewPanelView.swift
│   └── Shared/
│       ├── HotkeyRecorderView.swift
│       ├── APIKeyFieldView.swift
│       └── ToastView.swift
└── Components/
    └── DesignSystem/
        ├── Colors.swift
        ├── Typography.swift
        ├── Spacing.swift
        └── ButtonStyles.swift
```

### Key Decisions

- **SwiftData** for persistence (Action, Provider, HistoryRecord)
- **macOS Keychain** for API keys — never in SwiftData or UserDefaults
- **Protocol-based services** for testability
- **Dependency injection via init** — no singletons (`static let shared` is forbidden)
- **`@Observable` ViewModels** — no TCA, no Combine for new code
- **`@Query` in views** for read-only lists; `ModelContext` in services for mutations
- **One `ModelContainer`** at app level
- **`async/await`** structured concurrency — no GCD
- **`os.Logger`** — no `print()`

---

## 2. Phase 1: Foundation

### 2a. Xcode Project Scaffold

**Target:** macOS App, deployment target macOS 14.0, Swift 6

**Configuration:**
- `Info.plist`: `LSUIElement = YES` (hide dock icon by default)
- Entitlements: App Sandbox OFF (Accessibility API requires it)
- Bundle identifier: `com.indraft.app`
- `InDraftApp.swift`: `@main` struct with `MenuBarExtra` scene, `.modelContainer(for: [Action.self, Provider.self, HistoryRecord.self])`
- `AppDelegate.swift`: `NSApplicationDelegate` with `applicationDidFinishLaunching` hook
- Test target: `InDraftTests` with in-memory `ModelConfiguration(isStoredInMemoryOnly: true)`

### 2b. Design System

**`Colors.swift`** — `Color` extensions for all tokens from DESIGN.md:

| Token | Hex | Usage |
|-------|-----|-------|
| `surface` | `#faf9f6` | Base "Warm Bone" canvas |
| `onSurface` | `#2f3430` | Primary text (Charcoal) |
| `onSurfaceVariant` | `#5c605c` | Secondary text / metadata |
| `secondaryContainer` | `#d3e5f0` | Accent — active states, selection pills |
| `onSecondaryContainer` | `#43545d` | Text on accent |
| `surfaceContainer` | `#edeeea` | Card backgrounds |
| `surfaceContainerHigh` | `#e6e9e4` | Elevated surfaces |
| `surfaceContainerHighest` | `#e0e4de` | Highest elevation |
| `surfaceContainerLow` | `#f4f4f0` | Input field troughs |
| `surfaceContainerLowest` | `#ffffff` | Only pure white allowed |
| `surfaceDim` | `#d6dbd5` | Peripheral panels |
| `outlineVariant` | `#afb3ae` | Ghost borders (at 15% opacity) |
| `primary` | `#5a5f62` | Button backgrounds |
| `onPrimary` | `#f4f8fc` | Button text |
| `error` | `#9f403d` | Error states |
| `errorContainer` | `#fe8983` | Error backgrounds |
| `onError` | `#fff7f6` | Error text |

Plus all remaining tokens from DESIGN.md Full Color Token Reference.

**`Typography.swift`** — Font definitions:

| Scale | Font | Size | Usage |
|-------|------|------|-------|
| `displayMd` | Manrope | 2.75rem (44pt) | Empty state headers |
| `headlineLg` | Manrope | 1.75rem (28pt) | Page titles |
| `headlineMd` | Manrope | 1.5rem (24pt) | Section headers |
| `titleMd` | Inter | 1.125rem (18pt) | Sidebar titles |
| `titleSm` | Inter | 1rem (16pt) | Section headers, sidebar items |
| `bodyLg` | Inter | 1rem (16pt) | Body text |
| `bodySm` | Inter | 0.875rem (14pt) | Secondary body |
| `labelLg` | Inter | 0.875rem (14pt) | Button labels |
| `labelSm` | Inter | 0.6875rem (11pt) | Keyboard shortcuts, micro-metadata |
| `kbd` | SF Mono | 0.6875rem (11pt) | Keyboard shortcut display |

Manrope and Inter will be bundled as custom fonts in the app bundle.

**`Spacing.swift`** — Constants:

| Name | Value |
|------|-------|
| `spacing1` | 4 (0.25rem) |
| `spacing2` | 8 (0.5rem) |
| `spacing3` | 12 (0.75rem) |
| `spacing4` | 22 (1.4rem) |
| `spacing6` | 32 (2rem) |
| `spacing8` | 44 (2.75rem) |
| `spacing12` | 64 (4rem) |
| `spacing16` | 88 (5.5rem) |

**`ButtonStyles.swift`** — Three styles:

- **Primary:** `primary` background, `onPrimary` text, 8px radius
- **SecondaryPill:** `secondaryContainer` background, `onSecondaryContainer` text, fully rounded
- **Tertiary:** No background, `onSurface` text, `surfaceContainerHigh` background on hover

### 2c. Data Models

**Enums** (all `String` raw value, `Codable`):

```swift
enum OutputBehavior: String, Codable { case replace, preview, clipboard }
enum ProviderMode: String, Codable { case active, fixed }
enum AppStatus: String, Codable { case idle, processing, success, error, permissionRequired }
enum TestStatus: String, Codable { case untested, success, failed }
enum TransformationStatus: String, Codable { case success, error }
```

**`Action` model:**
- `id: UUID` (set in init)
- `name: String` (required, max 50 chars)
- `prompt: String` (required, max 2000 chars)
- `hotkey: String?` (nil = no hotkey)
- `outputBehavior: OutputBehavior` (default: `.replace`)
- `providerMode: ProviderMode` (default: `.active`)
- `provider: Provider?` (nil when providerMode == .active)
- `modelOverride: String?`
- `isEnabled: Bool` (default: true)
- `sortOrder: Int` (default: 0)
- `createdAt: Date`, `updatedAt: Date`

**`Provider` model:**
- `id: UUID`
- `displayName: String` (max 50 chars)
- `baseURL: String` (validated HTTPS)
- `apiKeyReference: String` (Keychain lookup key)
- `defaultModel: String`
- `isEnabled: Bool` (default: true)
- `isActive: Bool` (default: false)
- `lastTestStatus: TestStatus` (default: `.untested`)
- `lastTestError: String?`
- `lastTestedAt: Date?`
- `createdAt: Date`, `updatedAt: Date`
- `actions: [Action]` (inverse relationship)

**`HistoryRecord` model:**
- `id: UUID`
- `timestamp: Date`
- `sourceApp: String`
- `actionID: UUID`, `actionName: String` (snapshot)
- `providerID: UUID`, `providerName: String` (snapshot), `modelName: String`
- `originalText: String`, `transformedText: String`
- `latencyMs: Int`
- `status: TransformationStatus`
- `errorCode: String?`, `errorMessage: String?`

**Relationship rules:**
- Deleting a Provider nullifies `Action.provider` for referencing actions, switches to `providerMode = .active`
- Deleting an Action does NOT delete its HistoryRecords
- HistoryRecord stores name snapshots (survives action/provider deletion)
- Exactly one Provider has `isActive = true` (enforced at service layer)

### Phase 1 TDD Plan

| Test | What It Validates |
|------|-------------------|
| Enum raw values | All enums encode/decode correctly with String raw values |
| Action init defaults | Default values for outputBehavior, providerMode, isEnabled, sortOrder |
| Provider init defaults | Default values for isEnabled, isActive, lastTestStatus |
| HistoryRecord init | All snapshot fields stored independently |
| ModelContainer setup | All 3 model types register without error |
| Provider-Action relationship | Delete provider → action.provider becomes nil |
| Action deletion preserves history | Delete action → history records survive |
| Color tokens | All colors resolve to expected RGB values |
| Spacing constants | Values match DESIGN.md spec |
| Typography | Font names and sizes resolve correctly |

---

## 3. Phase 2: Core Services

Detailed spec written when Phase 1 completes. Summary:

- `KeychainService` — protocol `KeychainStoring`, CRUD for API keys
- `AIProviderService` — protocol `AIProviding`, OpenAI chat completions, connection test
- `ClipboardService` — protocol `ClipboardManaging`, NSPasteboard save/restore
- `PermissionService` — protocol `PermissionChecking`, AX permission status + polling
- `HistoryService` — protocol `HistoryManaging`, CRUD, retention cleanup, search

All services tested with mocks/in-memory stores.

---

## 4. Phase 3: Transformation Pipeline + Hotkeys

Detailed spec written when Phase 2 completes. Summary:

- `TextCaptureService` — AX API read + clipboard fallback chain
- `TextReplacementService` — AX API write + clipboard fallback chain
- `TransformationService` — orchestrator (capture → AI → replace → log)
- `HotkeyService` — Carbon/CGEvent global hotkey registration
- Full fallback chain integration tests with mock services

---

## 5. Phase 4: Menu Bar + Settings UI

Detailed spec written when Phase 3 completes. Summary:

- `MenuBarExtra` dropdown with provider status, action list, retry last
- Menu bar icon state machine (idle/processing/success/error/permission)
- Settings window: General, Actions, Providers, History, Diagnostics tabs
- Action editor and Provider editor sheet/modals
- All views follow DESIGN.md tokens and reference design screenshots

---

## 6. Phase 5: Onboarding + History + Preview + Toast

Detailed spec written when Phase 4 completes. Summary:

- 7-step onboarding wizard with real-time permission detection
- History window: searchable, expandable records, copy/retry/delete
- Preview panel: floating window with accept/reject/copy
- Toast notifications: near menu bar, no focus steal
- Default actions seeded on first launch (3 defaults from PRD)

---

## 7. Design References

UI implementation references for Phases 4-5:

| Screenshot | View |
|-----------|------|
| `designs/01-menu-bar-dropdown.png` | MenuBarDropdownView |
| `designs/02-onboarding-welcome.png` | WelcomeView |
| `designs/03-onboarding-accessibility.png` | AccessibilityPermissionView |
| `designs/04-onboarding-add-provider.png` | AddProviderView |
| `designs/05-onboarding-add-provider-alt.png` | AddProviderView (alt) |
| `designs/06-onboarding-complete.png` | OnboardingCompleteView |
| `designs/07-settings-actions.png` | ActionsSettingsView |
| `designs/08-action-editor-modal.png` | ActionEditorView |
| `designs/09-action-editor-modal-alt.png` | ActionEditorView (alt) |
| `designs/10-settings-providers.png` | ProvidersSettingsView |
| `designs/11-settings-diagnostics.png` | DiagnosticsSettingsView |
| `designs/12-transformation-history.png` | HistoryWindowView |
| `designs/13-preview-panel.png` | PreviewPanelView |
| `designs/14-preview-panel-alt.png` | PreviewPanelView (alt) |
| `designs/15-history-alt.png` | HistoryWindowView (alt) |

---

## 8. Constraints & Standards

- Follow all guidelines in `.trellis/spec/frontend/` and `.trellis/spec/backend/`
- No singletons, no `print()`, no GCD, no secrets outside Keychain
- All errors use domain-specific `LocalizedError` enums
- `os.Logger` for all logging with privacy annotations
- HTTPS-only provider URLs
- App Sandbox OFF for Accessibility API access
- TDD: write failing test → implement minimal fix → verify pass
