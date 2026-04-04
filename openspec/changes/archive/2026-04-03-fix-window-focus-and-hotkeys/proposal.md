## Why

Settings and History windows sometimes fail to appear in front when opened from the menu bar dropdown. The current approach toggles `NSApp.setActivationPolicy(.regular)` temporarily, which shows a dock icon and doesn't reliably bring windows to front. The dock icon should never appear — the app is a pure menu bar utility. Additionally, the default action hotkeys need to be verified as `⌃⌥1`, `⌃⌥2`, `⌃⌥3`.

## What Changes

- **Remove dock icon entirely**: Remove the `showDockIcon` user preference and all `setActivationPolicy(.regular)` toggling. The app stays as `.accessory` (LSUIElement) permanently — no dock icon, ever.
- **Fix window activation**: Replace the activation-policy-toggle approach with a reliable `NSApp.activate()` + `window.orderFrontRegardless()` pattern that works for LSUIElement apps without needing a dock icon.
- **Remove dock icon setting from UI**: Remove the "Show Dock Icon" toggle from General Settings since the app should never show in the dock.
- **Verify default hotkeys**: Confirm default actions use `control+option+1/2/3` (already defined in Constants.swift — verify end-to-end registration).

## Capabilities

### New Capabilities

### Modified Capabilities
- `app-core`: Window activation behavior changes — always LSUIElement, no dock icon toggle. Settings/History windows must reliably come to front without activation policy changes.

## Impact

- **Code**: `SettingsWindowController.swift`, `HistoryWindowController.swift` — remove `setActivationPolicy` toggling, use `orderFrontRegardless()`. `GeneralSettingsView.swift` — remove dock icon toggle. `AppDelegate.swift` — simplify to always set `.accessory`. `Constants.swift` — remove `showDockIcon` key.
- **Tests**: Update `TransformFlowTests` that reference `showDockIcon`. Add tests for window controller activation behavior.
- **User-facing**: Dock icon setting removed. Windows always activate reliably from menu bar.
