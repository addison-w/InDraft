## 1. Menu Bar Dropdown — Open Settings Button

- [x] 1.1 Add an "Open Settings" button to `MenuBarDropdownView.swift` visible only when `appState.status == .permissionRequired`, styled consistently with the design system
- [x] 1.2 Wire the button to call `AccessibilityService.openAccessibilitySettings()`

## 2. Diagnostics Settings — Open Settings Button

- [x] 2.1 Add an "Open System Settings" button to the accessibility card in `DiagnosticsSettingsView.swift`, visible only when `accessibilityGranted` is false
- [x] 2.2 Wire the button to call `AccessibilityService.openAccessibilitySettings()`

## 3. Hotkey Error Toast — Update Message

- [x] 3.1 Update the toast message in `AppCoordinator.swift` from "check Settings > Diagnostics" to "use the menu bar to open Settings"

## 4. Verify

- [x] 4.1 Build the project and verify no compilation errors
- [x] 4.2 Run all unit tests and verify they pass
