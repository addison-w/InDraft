## 1. Tests First (TDD)

- [x] 1.1 Add tests for SettingsWindowController: window activation uses `orderFrontRegardless()` and `NSApp.activate()`, never calls `setActivationPolicy(.regular)`
- [x] 1.2 Add tests for HistoryWindowController: window activation uses `orderFrontRegardless()` and `NSApp.activate()`, never calls `setActivationPolicy(.regular)`
- [x] 1.3 Update existing TransformFlowTests to remove `showDockIcon` references
- [x] 1.4 Add test verifying default actions have correct hotkeys: control+option+1, control+option+2, control+option+3

## 2. Remove Dock Icon Preference

- [x] 2.1 Remove `showDockIcon` key from `Constants.UserDefaultsKeys`
- [x] 2.2 Remove "Show Dock Icon" toggle from `GeneralSettingsView.swift`
- [x] 2.3 Simplify `AppDelegate.swift` to always set `.accessory` without checking `showDockIcon`

## 3. Fix Window Activation

- [x] 3.1 Refactor `SettingsWindowController.showSettings()`: replace `setActivationPolicy(.regular)` + `makeKeyAndOrderFront` with `orderFrontRegardless()` + `NSApp.activate()`, remove close-notification activation policy revert
- [x] 3.2 Refactor `HistoryWindowController.showHistory()`: replace `setActivationPolicy(.regular)` + `makeKeyAndOrderFront` with `orderFrontRegardless()` + `NSApp.activate()`, remove close-notification activation policy revert

## 4. Verify Hotkeys

- [x] 4.1 Verify `Constants.DefaultActions` uses `kVK_ANSI_1/2/3` with `controlKey | optionKey` modifiers (already correct — run tests to confirm)

## 5. Build & Verify

- [x] 5.1 Build project and ensure no compilation errors
- [x] 5.2 Run full test suite and verify all tests pass
