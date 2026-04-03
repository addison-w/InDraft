## Context

InDraft is a greenfield macOS menu bar application that transforms selected text in place using AI. There is no existing codebase. The app runs as a background daemon (LSUIElement) with a menu bar presence, intercepting global hotkeys to trigger text transformations across any macOS app.

The PRD defines 19 distinct UI views, 10 capability areas, and integration with macOS Accessibility APIs, Keychain Services, and global hotkey registration. The design reference screenshots show a minimalist, editorial aesthetic — warm bone/cream backgrounds, serif headlines, monospaced labels, and flat UI with minimal shadows.

Key constraints:
- macOS 14+ (Sonoma) only — can leverage latest SwiftUI and SwiftData
- Must work across top 10 macOS apps via Accessibility API with clipboard fallback
- BYOK model — no bundled AI provider, user provides OpenAI-compatible API keys
- Local-first privacy — no telemetry, no cloud sync, no external network calls except to user's provider
- TDD approach required for implementation

## Goals / Non-Goals

**Goals:**
- Ship a reliable, performant menu bar utility with < 2s hotkey-to-replacement latency
- Achieve >= 90% text capture/replace success rate across top 10 macOS apps
- Deliver a polished minimalist UI matching the design system (bone palette, serif typography, flat cards)
- Build a modular architecture where each capability is independently testable
- Apply harness engineering principles: structured context handoffs, feature-based sprints, clear component boundaries

**Non-Goals:**
- Rich text formatting preservation (plain text only for MVP)
- Non-OpenAI-compatible providers (Anthropic native, Google, local models)
- Cross-device sync or team features
- Universal action picker (post-MVP)
- Workflow automation chains

## Decisions

### D1: SwiftUI + SwiftData stack

**Choice:** SwiftUI for all UI, SwiftData for persistence, targeting macOS 14+.

**Rationale:** SwiftData provides native Core Data integration without boilerplate. SwiftUI on macOS 14 has mature support for settings windows, menu bar extras, sheets, and floating panels. Targeting Sonoma-only avoids compatibility workarounds.

**Alternatives considered:**
- AppKit + SQLite: More control but significantly more boilerplate. SwiftUI is sufficient for this UI complexity.
- Core Data directly: SwiftData wraps Core Data with less code and better SwiftUI integration.

### D2: App architecture — modular service layer with protocol-based DI

**Choice:** Organize the app into a service layer with protocol-defined boundaries. Each capability maps to one or more services. Use dependency injection via environment objects and initializer injection for testability.

```
InDraft/
├── App/                    # App entry point, MenuBarExtra, app lifecycle
├── Models/                 # SwiftData models (Action, Provider, HistoryRecord)
├── Services/               # Protocol-defined service layer
│   ├── TextCaptureService  # AX API + clipboard fallback
│   ├── TextReplaceService  # AX API + clipboard fallback
│   ├── HotkeyService       # Global hotkey registration
│   ├── TransformService    # Orchestrates capture → API → replace
│   ├── ProviderService     # API calls to OpenAI-compatible endpoints
│   ├── KeychainService     # Secure API key storage
│   └── HistoryService      # History CRUD + retention
├── Views/                  # SwiftUI views organized by feature
│   ├── MenuBar/
│   ├── Onboarding/
│   ├── Settings/
│   ├── History/
│   └── Preview/
├── ViewModels/             # ObservableObject view models
└── Utilities/              # Extensions, constants, hotkey codes
```

**Rationale:** Protocol-based services enable TDD — each service can be mocked in tests. The flat service layer avoids over-abstraction while keeping clear boundaries. This aligns with harness engineering: each component encodes a clear responsibility boundary.

**Alternatives considered:**
- MVVM with fat view models: Harder to test service interactions in isolation.
- The Composable Architecture (TCA): Powerful but heavy for this app's complexity. Would slow initial development.

### D3: Text capture/replace — Accessibility API primary, clipboard fallback

**Choice:** Two-strategy chain for both capture and replacement:
1. **Primary:** AXUIElement API to read/write the focused element's selected text
2. **Fallback:** Save clipboard → simulate Cmd+C/V → read/write clipboard → restore original

**Rationale:** AX API is the cleanest path (no clipboard side effects) but not universally supported. The clipboard fallback covers apps with limited AX support. The fallback chain is automatic — user sees no difference.

**Key implementation details:**
- Use `AXUIElementCopyAttributeValue` with `kAXSelectedTextAttribute` for capture
- Use `AXUIElementSetAttributeValue` with `kAXSelectedTextAttribute` for replacement
- Clipboard operations use `NSPasteboard.general` with save/restore
- Simulate keystrokes via `CGEvent` for Cmd+C/V fallback
- 500ms timeout for capture, 30s clipboard restore window

### D4: Global hotkeys — Carbon API via modern wrapper

**Choice:** Use the Carbon `RegisterEventHotKey` API wrapped in a Swift service class. Each action's hotkey is registered/unregistered independently.

**Rationale:** Carbon hotkey API remains the only reliable way to register system-wide hotkeys on macOS. Modern alternatives (NSEvent.addGlobalMonitorForEvents) don't capture events when other apps have focus in all cases. The wrapper abstracts the C API behind a clean Swift protocol.

**Alternatives considered:**
- NSEvent global monitor: Unreliable for key combinations in all app contexts.
- MASShortcut/HotKey libraries: External dependencies. The Carbon API is straightforward enough to wrap directly.

### D5: Provider API integration — URLSession with async/await

**Choice:** Build a lightweight OpenAI-compatible client on URLSession using Swift concurrency. No third-party HTTP libraries.

**Rationale:** The API surface is a single endpoint (`POST /chat/completions`). URLSession with async/await is sufficient. Avoiding external dependencies keeps the app lightweight and auditable.

**Request flow:**
1. Build `ChatCompletionRequest` with system prompt (action prompt) + user message (selected text)
2. Send via URLSession with API key in Authorization header
3. Parse `ChatCompletionResponse` to extract transformed text
4. Handle errors with specific error types (auth, network, timeout, parse)

### D6: Keychain storage for API keys

**Choice:** Store API keys in macOS Keychain using Security framework. Store a reference identifier in SwiftData; the actual key is only in Keychain.

**Rationale:** PRD mandates Keychain storage. This prevents keys from appearing in app databases, preferences files, or backups. The reference ID pattern means SwiftData never contains sensitive material.

### D7: Menu bar implementation — MenuBarExtra with SwiftUI

**Choice:** Use SwiftUI `MenuBarExtra` with a custom view for the dropdown. App runs as LSUIElement (no dock icon by default, toggleable).

**Rationale:** MenuBarExtra is the native SwiftUI API for menu bar apps on macOS 13+. It supports custom views (not just NSMenu items), enabling the styled dropdown shown in the designs.

### D8: State machine for app status

**Choice:** Model the menu bar icon state as an explicit state machine: `idle → processing → success/error → idle`. Use a `@Published` property on the app's main state object.

**States:** idle, processing, success (3s auto-dismiss), error (10s auto-dismiss), permissionRequired (persistent)

**Rationale:** Explicit states prevent invalid transitions and make status feedback testable. The state machine drives both the menu bar icon and toast notifications.

### D9: History with SwiftData + auto-pruning

**Choice:** Store history records in SwiftData with auto-pruning on app launch based on configurable retention (7/30/90 days or unlimited).

**Rationale:** SwiftData integrates natively with SwiftUI for list rendering and search. Auto-pruning on launch keeps storage bounded without background processes.

### D10: Minimalist design system implementation

**Choice:** Implement a design system matching the reference screenshots:
- **Palette:** Bone/cream background (#F5F0EB), warm grays, dark charcoal text
- **Typography:** Serif for headlines (Georgia or system serif), system font for body, monospaced for labels/hotkeys
- **Components:** Flat cards with subtle borders, no heavy shadows, pill-shaped badges, toggle switches
- **Layout:** Generous whitespace, left sidebar navigation in settings, centered content in onboarding

**Rationale:** The designs show a distinctive editorial/minimalist aesthetic that differentiates from typical macOS app chrome. This should be encoded as SwiftUI ViewModifiers and a Theme struct for consistency.

## Risks / Trade-offs

**[Accessibility API inconsistency across apps]** → Test against top 10 apps explicitly. Log which apps trigger fallback. Maintain an internal compatibility table. The clipboard fallback chain provides graceful degradation.

**[Carbon hotkey API deprecation]** → Carbon hotkeys have been "deprecated" for years but remain the only working system-wide solution. Monitor WWDC for alternatives. The service protocol allows swapping implementations.

**[SwiftData maturity on macOS]** → SwiftData is newer and may have edge cases. Mitigation: keep models simple (no complex relationships), write integration tests against real SwiftData stores.

**[Clipboard race conditions]** → Multiple rapid hotkey presses could interleave clipboard operations. Mitigation: queue transformations serially via an actor. Only one transformation runs at a time.

**[Menu bar custom view limitations]** → MenuBarExtra custom views have size/interaction constraints. Mitigation: keep dropdown simple (list of items), use separate windows for complex interactions (settings, history).

**[TDD with macOS system APIs]** → Accessibility API and hotkey registration are hard to unit test. Mitigation: wrap behind protocols, test with mocks for unit tests, use integration tests for actual system interaction.
