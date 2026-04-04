## 1. Accessibility Polling in AppCoordinator

- [x] 1.1 Add a `Timer?` property to `AppCoordinator` for accessibility polling
- [x] 1.2 Start a 2-second polling timer when `appState.status` is set to `permissionRequired`
- [x] 1.3 On each tick, check `AccessibilityService.isAccessibilityGranted` — if granted, call `appState.setIdle()`, re-register hotkeys, and invalidate the timer
- [x] 1.4 Invalidate the timer in `deinit`

## 2. Live Accessibility Status in DiagnosticsSettingsView

- [x] 2.1 Add a `Timer?` state property to `DiagnosticsSettingsView`
- [x] 2.2 Start a 2-second polling timer in `onAppear` that calls `checkAccessibility()`
- [x] 2.3 Invalidate the timer in `onDisappear`

## 3. Filter Dropdown to Enabled Actions Only

- [x] 3.1 In `MenuBarDropdownView.actionListSection`, filter `actions` to only include those with `enabled == true`

## 4. Verify

- [x] 4.1 Build the project and verify no compilation errors
- [x] 4.2 Run all unit tests and verify they pass
