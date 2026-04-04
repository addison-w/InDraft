## 1. OnboardingWindowController

- [x] 1.1 Add `window.level = .floating` to `OnboardingWindowController` in `InDraft/App/OnboardingWindowController.swift` immediately after window creation, before the window is first displayed

## 2. SettingsWindowController

- [x] 2.1 Add `window.level = .floating` to `SettingsWindowController` in `InDraft/App/SettingsWindowController.swift` immediately after window creation, before the window is first displayed

## 3. HistoryWindowController

- [x] 3.1 Add `window.level = .floating` to `HistoryWindowController` in `InDraft/App/HistoryWindowController.swift` immediately after window creation, before the window is first displayed

## 4. Verification

- [x] 4.1 Build the project and verify zero compilation errors
- [ ] 4.2 Launch the app, open Settings from the menu bar dropdown, switch to another app, and confirm the Settings window remains visible above the other app
- [ ] 4.3 Open History from the menu bar dropdown, switch to another app, and confirm the History window remains visible above the other app
- [ ] 4.4 Reset onboarding state, relaunch the app, switch to another app during onboarding, and confirm the Onboarding window remains visible above the other app
- [ ] 4.5 Confirm no dock icon appears and the app remains an LSUIElement throughout all tests
