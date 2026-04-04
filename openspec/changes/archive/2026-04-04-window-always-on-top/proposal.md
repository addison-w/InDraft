## Why

InDraft runs as an LSUIElement with activation policy `.accessory`, meaning it has no dock icon. When a user opens a Settings, History, or Onboarding window and then switches to another application, the InDraft window gets covered and there is no dock icon to click to bring it back. The existing `orderFrontRegardless()` + `NSApp.activate()` calls only work on initial show -- they do not prevent other windows from covering InDraft windows afterward. This makes the app's windows effectively unreachable once buried.

## What Changes

- **Set `window.level = .floating` on OnboardingWindowController** so the onboarding window stays above normal application windows at all times
- **Set `window.level = .floating` on SettingsWindowController** so the settings window stays above normal application windows at all times
- **Set `window.level = .floating` on HistoryWindowController** so the history window stays above normal application windows at all times

## Non-goals

- Changing the activation policy from `.accessory` -- the app MUST remain an LSUIElement
- Adding a dock icon or any alternative window-surfacing mechanism
- Adding user-configurable "always on top" preference (may be considered in a future change)
- Modifying any services, protocols, or data models
- Changing the existing `orderFrontRegardless()` / `NSApp.activate()` calls -- those remain for initial activation

## Capabilities

### New Capabilities

- `window-focus-management`: Window level and persistence behavior for LSUIElement apps -- ensures all app windows remain accessible by floating above normal windows

### Modified Capabilities

- `app-core`: The existing "Settings window always activates to front" and "History window always activates to front" requirements are being strengthened to specify that windows SHALL remain visible above other windows at all times, not just on initial activation

## Impact

- **Files modified**: `InDraft/App/OnboardingWindowController.swift`, `InDraft/App/SettingsWindowController.swift`, `InDraft/App/HistoryWindowController.swift`
- **Services affected**: None
- **Models affected**: None
- **Dependencies**: None -- uses built-in NSWindow.Level API available since macOS 10.0
- **macOS API constraints**: `NSWindow.Level.floating` is available on all supported macOS versions (14+)
- **Rollback plan**: Remove `window.level = .floating` lines from each controller. Windows revert to default `.normal` level. No data migration or state changes involved.

## Complexity

**S** (Small) -- Three one-line additions to existing window controllers. No architectural changes, no new files, no new dependencies.
