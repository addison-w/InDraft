## Context

InDraft is a macOS menu bar app with a warm, editorial light-mode design system (Theme.swift). All colors are hardcoded static values. The History window shows expanded detail views with unbounded text height. There is no diff visualization. The Action model already has `provider_mode` and `provider_id` fields in the spec but these are not yet implemented in the codebase — the current `Action.swift` model lacks these fields and `TransformService` always uses the global active provider.

## Goals / Non-Goals

**Goals:**
- Implement dark mode that respects macOS system appearance with manual override
- Constrain history detail views to a max height with independent scrolling
- Show word-level diffs in the transformed text column
- Enable per-action provider/model override in the UI and transform pipeline

**Non-Goals:**
- Custom color themes beyond light/dark
- Character-level or syntax-aware diffing
- Provider fallback chains or load balancing
- Changes to activation policy or window management patterns

## Decisions

### 1. Dark Mode: Semantic Color Tokens via Color Assets

**Decision:** Replace all hardcoded `Color(hex:)` values in `Theme.Colors` with SwiftUI `Color("name")` references backed by an Asset Catalog color set with Light/Dark appearances.

**Rationale:** Asset Catalog color sets are the standard macOS approach. They automatically resolve per-appearance, work with SwiftUI's `preferredColorScheme`, and require no runtime branching. The alternative — runtime `@Environment(\.colorScheme)` checks scattered across views — would be fragile and repetitive.

**Appearance preference:** Add an `AppearanceMode` enum (`.system`, `.light`, `.dark`) stored in UserDefaults. Apply via `.preferredColorScheme()` on each root hosting view. When set to `.system`, pass `nil` to let macOS resolve automatically.

**Dark palette direction:** Invert the tonal hierarchy — dark warm gray backgrounds (`#1C1E1C`, `#252825`), light text (`#E8E8E4`), muted accent colors. Preserve the warm editorial feel by avoiding pure black/white. Window control colors remain the same (they already work on dark backgrounds).

### 2. History Scroll Containment: Max Height with ScrollView

**Decision:** Wrap each text column in `HistoryRecordDetailView` with a `ScrollView` inside a `.frame(maxHeight: 300)` container.

**Rationale:** This is the simplest SwiftUI approach. The 300px max height provides ~15 lines of monospaced text before scrolling kicks in, which covers most use cases. No new components needed. The alternative — a virtualized text view — is overengineered for this use case.

**Scroll indicator:** Use the default macOS scroll indicator (shows on hover). No custom scrollbar styling needed.

### 3. History Diff Highlighting: Word-Level Diff with Attributed Text

**Decision:** Implement a `DiffService` that computes word-level diffs using Swift's `CollectionDifference` API on word-tokenized arrays, then render with SwiftUI `Text` concatenation using colored highlights.

**Rationale:** `CollectionDifference` (available since Swift 5.1) provides an efficient, stdlib-native diff algorithm. Word-level granularity is the right balance — character-level is noisy, sentence-level misses details. The alternative — a third-party diff library — adds an unnecessary dependency.

**Rendering approach:** Build an `AttributedString` or concatenated `Text` views:
- Unchanged words: default text color
- Inserted words (in transformed): green background tint (`statusGreenBg`)
- Removed words (from original, shown in transformed column): red strikethrough with muted color

**Toggle:** Add a "Show Changes" toggle in the detail view header so users can switch between plain text and diff view.

### 4. Per-Action Model Override: Action Model Extension + UI Picker

**Decision:** Add `providerID: UUID?` and `modelOverride: String?` fields to the `Action` SwiftData model. Add a provider/model picker section in `ActionsSettingsView` that appears when the user selects "Fixed" provider mode.

**Rationale:** The spec already defines `provider_mode` (active|fixed), `provider_id`, and `model_override` on the Action model. This implements that spec. The transform pipeline in `AppCoordinator` will check `action.providerMode` before falling back to the global active provider.

**UI design:** In the action editor, add an `InkSegmentPicker` for provider mode (Active / Fixed). When "Fixed" is selected, show a dropdown of enabled providers and a text field for model override. When "Active" is selected, hide the provider picker and show "Uses global active provider" as helper text.

**Pipeline change:** In `AppCoordinator.handleHotkeyPress`, resolve provider:
1. If `action.providerMode == .fixed` and `action.providerID` is set → fetch that provider
2. Else → use global active provider (current behavior)
3. If resolved provider has `modelOverride` on the action → pass it to `ProviderService` instead of `provider.defaultModel`

## Risks / Trade-offs

**[Risk] Dark mode color quality** → Mitigation: Define a complete dark palette upfront in DESIGN.md. Test every view in both modes. Use semantic token names that describe purpose, not appearance (e.g., `background` not `bone`).

**[Risk] Diff performance on large texts** → Mitigation: Word tokenization + `CollectionDifference` is O(n*d) where d is edit distance. For typical text transformations (paragraphs, not novels), this is sub-millisecond. Add a size guard: skip diff for texts > 10,000 words and show plain text.

**[Risk] SwiftData migration for new Action fields** → Mitigation: New fields are all optional (`UUID?`, `String?`) with nil defaults. SwiftData lightweight migration handles this automatically — no manual migration plan needed.

**[Risk] Fixed provider deleted while assigned to action** → Mitigation: Already covered in the actions-engine spec — when a provider is deleted, any action with that `providerID` gets reset to `providerMode = .active` and `providerID = nil`.

## Testability

**Dark mode:**
- Unit test: `AppearanceMode` enum serialization to/from UserDefaults
- UI test: Toggle appearance preference, verify window respects the setting
- Manual: Visual inspection in both modes across all windows

**History scroll containment:**
- UI test: Expand a history record with long text, verify scroll behavior
- Manual: Visual check that text doesn't push list items off-screen

**Diff highlighting:**
- Unit test: `DiffService` with known input pairs — verify word-level insertions/removals are correctly identified
- Unit test: Edge cases — empty strings, identical strings, completely different strings
- Unit test: Performance test with large text (> 1000 words)

**Per-action model override:**
- Unit test: `Action` model with `providerMode = .fixed` and `providerID` set
- Unit test: Provider resolution logic in coordinator — fixed vs active paths
- Unit test: Fixed provider deletion cascading to action reset
- Integration test: End-to-end transform with fixed provider

**Mock implementations needed:**
- `MockDiffService` — returns predetermined diff results for UI testing
- No new service protocols needed for the other features (they extend existing services)

## AppKit/SwiftUI Bridging

- **Appearance override**: Applied via `.preferredColorScheme()` on SwiftUI root views inside `NSHostingController`. For the `NSStatusBarButton` (menu bar icon), appearance is inherited from the system — no bridging needed.
- **Window controllers**: `SettingsWindowController`, `HistoryWindowController`, and `OnboardingWindowController` host SwiftUI views — the appearance modifier on the hosted view is sufficient.
- **Menu bar popover**: The `NSPopover` content view inherits system appearance automatically. The `.preferredColorScheme()` override on `MenuBarDropdownView` handles manual overrides.

## AppCoordinator Changes

- `handleHotkeyPress`: Add provider resolution step before calling `TransformService.execute()`. Check `action.providerMode` and resolve the correct provider + model.
- No changes to window controller lifecycle or service initialization.

## Open Questions

- **Diff toggle default**: Should "Show Changes" default to on or off in history detail? Recommend: default on, since it's the primary value-add of this feature.
- **Dark mode accent color**: Should the pale blue accent (`#D3E5F0`) shift to a different hue in dark mode, or just adjust brightness? Recommend: same hue, adjusted to ~30% brightness for dark backgrounds.
