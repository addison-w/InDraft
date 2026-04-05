## 1. Dark Mode — Color System Refactor

- [x] 1.1 Create Asset Catalog color sets with Light/Dark appearances for all Theme.Colors values (background, cardBackground, textPrimary, textSecondary, accent, status colors, etc.)
- [x] 1.2 Define dark palette values: warm dark grays (#1C1E1C background, #252825 card, #E8E8E4 text), muted accents, adjusted status colors
- [x] 1.3 Replace all `Color(hex:)` static values in Theme.Colors with `Color("tokenName")` Asset Catalog references
- [x] 1.4 Update CardStyle, InputFieldStyle, BadgeStyle, PrimaryButtonStyle, SecondaryButtonStyle, WabiSabiToggleStyle to use semantic tokens (verify they resolve correctly in both modes)
- [x] 1.5 Update InkSegmentPicker, Keycap, KeycapRow, StatusPill to use semantic tokens

## 2. Dark Mode — Appearance Preference

- [x] 2.1 Create `AppearanceMode` enum (system, light, dark) with RawRepresentable for UserDefaults storage
- [x] 2.2 Add `appearanceMode` key to UserDefaultsKeys in Constants.swift (default: .system)
- [x] 2.3 Add appearance selector (InkSegmentPicker with System/Light/Dark) to GeneralSettingsView
- [x] 2.4 Apply `.preferredColorScheme()` modifier on root views in SettingsWindowController, HistoryWindowController, OnboardingWindowController, and MenuBarController popover

## 3. Dark Mode — View Updates

- [x] 3.1 Audit and update MenuBarDropdownView, MenuBarMenuView, MenuBarIconView for dark mode
- [x] 3.2 Audit and update SettingsView, GeneralSettingsView, ActionsSettingsView, ProvidersSettingsView, HistorySettingsView for dark mode
- [x] 3.3 Audit and update HistoryWindowView, HistoryRecordRowView, HistoryRecordDetailView for dark mode
- [x] 3.4 Audit and update OnboardingContainerView and all onboarding step views for dark mode
- [x] 3.5 Audit and update PreviewPanelView, ToastView, WindowChromeView for dark mode
- [x] 3.6 Verify menu bar icon visibility on both light and dark menu bars

## 4. History Scroll Containment

- [x] 4.1 Wrap the original text section in HistoryRecordDetailView with ScrollView inside `.frame(maxHeight: 300)`
- [x] 4.2 Wrap the transformed text section in HistoryRecordDetailView with ScrollView inside `.frame(maxHeight: 300)`
- [x] 4.3 Verify short text displays at natural height without scrollbar and long text triggers scroll indicator

## 5. History Diff Highlighting — Diff Engine

- [x] 5.1 Create `DiffService` protocol with `func computeWordDiff(original: String, transformed: String) -> [DiffSegment]` method
- [x] 5.2 Define `DiffSegment` model: enum type (unchanged, inserted, removed) + text content
- [x] 5.3 Implement `LiveDiffService` using word tokenization + Swift `CollectionDifference` API
- [x] 5.4 Add 10,000-word performance guard — return nil if either text exceeds limit
- [x] 5.5 Write unit tests for DiffService: identical strings, completely different strings, word insertions, word removals, mixed changes, empty strings, large text guard

## 6. History Diff Highlighting — UI Rendering

- [x] 6.1 Add "Show Changes" toggle to HistoryRecordDetailView header (only visible for success records)
- [x] 6.2 Create `DiffTextView` SwiftUI component that renders `[DiffSegment]` as styled Text with green background for insertions, red strikethrough for removals
- [x] 6.3 Integrate DiffTextView into HistoryRecordDetailView transformed text column when toggle is enabled
- [x] 6.4 Show "Text too long for diff comparison" message when diff computation is skipped
- [x] 6.5 Verify diff rendering in both light and dark modes

## 7. Per-Action Model Override — Model & Pipeline

- [x] 7.1 Add `providerMode` (ProviderMode enum: active|fixed), `providerID` (UUID?), and `modelOverride` (String?) fields to the Action SwiftData model
- [x] 7.2 Update SeedData default actions to set providerMode=.active, providerID=nil, modelOverride=nil
- [x] 7.3 Update `ProviderService.transform()` to accept an optional model override parameter
- [x] 7.4 Update `AppCoordinator.handleHotkeyPress` to resolve provider based on action.providerMode — check fixed provider first, fall back to global active
- [x] 7.5 Add provider deletion cascade: when a provider is deleted, reset all actions with that providerID to providerMode=.active
- [x] 7.6 Write unit tests for provider resolution logic (active path, fixed path, fixed-with-model-override, deleted-provider fallback)

## 8. Per-Action Model Override — Settings UI

- [x] 8.1 Add provider mode InkSegmentPicker (Active / Fixed) to ActionsSettingsView action editor
- [x] 8.2 Add provider dropdown (Picker with enabled providers) visible when mode is Fixed
- [x] 8.3 Add model override text field visible when mode is Fixed, with placeholder "Provider default"
- [x] 8.4 Show "Uses global active provider" helper text when mode is Active
- [x] 8.5 Verify action editor layout in both light and dark modes

## 9. Integration & Verification

- [x] 9.1 Build the project and fix any compilation errors
- [x] 9.2 Run all unit tests and fix failures
- [ ] 9.3 Manual test: toggle appearance preference System/Light/Dark across all windows
- [ ] 9.4 Manual test: expand history record with long text, verify scroll containment
- [ ] 9.5 Manual test: expand history record, toggle diff view, verify highlighting
- [ ] 9.6 Manual test: create action with Fixed provider, trigger transformation, verify correct provider used
- [ ] 9.7 Manual test: delete a fixed provider, verify action resets to Active mode
