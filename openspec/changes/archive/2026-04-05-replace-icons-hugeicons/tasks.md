## 1. Package Setup

- [x] 1.1 Add HugeiconsSwiftUI SPM dependency to `project.yml` with pinned version
- [x] 1.2 Run `xcodegen generate` and verify package resolves with a clean build

## 2. Centralized Icon Mapping

- [x] 2.1 Create `InDraft/Utilities/IconProvider.swift` with `AppIcon` enum covering all 19 icon cases
- [x] 2.2 Add `var view: some View` computed property mapping each case to a Hugeicons view
- [x] 2.3 Add `func nsImage(size:color:) -> NSImage` extension using `ImageRenderer` for AppKit contexts
- [x] 2.4 Verify all Hugeicons identifiers exist in the package (compile check)

## 3. Menu Bar Icons

- [x] 3.1 Update `MenuBarController.swift` — replace 4 `NSImage(systemSymbolName:)` calls with `AppIcon.nsImage()` for idle/success/error/permissionRequired states
- [x] 3.2 Update `MenuBarIconView.swift` — replace `Image(systemName:)` calls with `AppIcon.view` for the SwiftUI status icon states
- [x] 3.3 Verify bouncing ball animation is preserved unchanged for processing state

## 4. Menu Bar Dropdown

- [x] 4.1 Update `MenuBarDropdownView.swift` — replace `iconForAction()` SF Symbol mapping with `AppIcon` equivalents for all action name patterns

## 5. Settings Views

- [x] 5.1 Update `SettingsView.swift` — replace tab icons (gearshape, bolt.fill, puzzlepiece.fill, clock) with `AppIcon` views
- [x] 5.2 Update `ActionsSettingsView.swift` — replace drag handle, chevron, and plus icons
- [x] 5.3 Update `ProvidersSettingsView.swift` — replace eye/eye-slash toggle, plus, chevron, and test result icons
- [x] 5.4 Update `HistorySettingsView.swift` — replace lock.shield privacy icon

## 6. History Views

- [x] 6.1 Update `HistoryWindowView.swift` — replace clock.arrow.circlepath and magnifyingglass icons
- [x] 6.2 Update `HistoryRecordRowView.swift` — replace chevron expand/collapse icons
- [x] 6.3 Update `HistoryRecordDetailView.swift` — replace doc.on.doc copy icon

## 7. Onboarding Views

- [x] 7.1 Update `AccessibilityStepView.swift` — replace gear and chevron icons
- [x] 7.2 Update `AddProviderStepView.swift` — replace checkmark.circle.fill and xmark.circle.fill icons
- [x] 7.3 Update `TestConnectionStepView.swift` — replace checkmark.circle.fill and xmark.circle.fill icons
- [x] 7.4 Update `SampleTransformStepView.swift` — replace checkmark icon

## 8. Shared Views

- [x] 8.1 Update `WindowChromeView.swift` — replace xmark close button icon
- [x] 8.2 Update `PreviewPanelView.swift` — replace ellipsis menu icon
- [x] 8.3 Update `ToastView.swift` — replace success/error/info toast icons

## 9. Cleanup & Verification

- [x] 9.1 Search codebase for remaining `Image(systemName:` and `NSImage(systemSymbolName:` — confirm zero results for replaced icons
- [x] 9.2 Build the project and resolve any compilation errors
- [ ] 9.3 Visual verification — run the app and check all icon states (menu bar, settings, history, onboarding, toasts)
