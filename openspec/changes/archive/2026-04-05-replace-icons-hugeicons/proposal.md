## Why

InDraft currently uses SF Symbols exclusively for all 19 unique icons across the app. While functional, SF Symbols are generic and used by every macOS app — they don't align with InDraft's "Technical Curator" design identity. Replacing them with Hugeicons (a modern, stroke-based icon library) gives the app a distinctive visual personality that reinforces the high-end utilitarian editorial aesthetic.

## What Changes

- **Add HugeiconsSwiftUI package** as a dependency via Swift Package Manager (`https://github.com/nicklaus-dev/hugeicons-swiftui.git`)
- **Replace all 36 SF Symbol references** (31 `Image(systemName:)` + 5 `NSImage(systemSymbolName:)`) with equivalent Hugeicons views across 16 files
- **Update MenuBarController** (AppKit layer) to render Hugeicons as `NSImage` for the status bar item
- **Update dynamic icon mapping** in `MenuBarDropdownView.iconForAction()` to use Hugeicons equivalents
- **Update toast and status icons** in `ToastView` and `MenuBarIconView` to use Hugeicons
- **Preserve the custom bouncing ball animation** for the processing state (not an icon replacement)

## Non-goals

- Redesigning the overall UI layout or spacing
- Changing icon colors or the Theme color system
- Replacing the custom Canvas-based bouncing ball animation
- Adding new icons beyond what currently exists
- Adopting Hugeicons Pro (paid) — using the free stroke-rounded set only

## Capabilities

### New Capabilities
- `hugeicons-integration`: SPM package integration, icon mapping from SF Symbols to Hugeicons equivalents, and NSImage rendering adapter for AppKit contexts

### Modified Capabilities
- `settings-ui`: Icon references in settings tabs and provider/action list items change from SF Symbols to Hugeicons
- `status-feedback`: Menu bar status icons and toast icons change from SF Symbols to Hugeicons

## Impact

- **Dependencies**: New SPM dependency — `HugeiconsSwiftUI` package
- **Build system**: `project.yml` (xcodegen) needs package dependency added
- **Views affected** (16 files):
  - `MenuBarIconView.swift`, `MenuBarDropdownView.swift`, `MenuBarController.swift`
  - `SettingsView.swift`, `ActionsSettingsView.swift`, `ProvidersSettingsView.swift`, `HistorySettingsView.swift`
  - `ToastView.swift`, `WindowChromeView.swift`, `PreviewPanelView.swift`
  - `HistoryWindowView.swift`, `HistoryRecordRowView.swift`, `HistoryRecordDetailView.swift`
  - `AccessibilityStepView.swift`, `AddProviderStepView.swift`, `TestConnectionStepView.swift`, `SampleTransformStepView.swift`
- **Services affected**: None (icons are purely view-layer)
- **Models affected**: None
- **macOS API constraints**: HugeiconsSwiftUI renders as SwiftUI views (paths), not SF Symbols — NSImage conversion needed for `MenuBarController` (AppKit)
- **Rollback plan**: Revert the SPM dependency addition and restore SF Symbol references — all changes are view-layer only with no data migration
- **Complexity**: **M** (medium) — straightforward 1:1 replacements across many files, with one non-trivial piece: NSImage rendering for the AppKit menu bar
