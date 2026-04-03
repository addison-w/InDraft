## 1. History Window Controller

- [x] 1.1 Create `HistoryWindowController.swift` with singleton pattern matching `SettingsWindowController`
- [x] 1.2 Add `configure(appState:modelContainer:)` method to `HistoryWindowController`
- [x] 1.3 Add `showHistory()` method that creates/reuses window and brings to front
- [x] 1.4 Configure `HistoryWindowController` in `AppDelegate` at app startup

## 2. Window Activation Fix

- [x] 2.1 Update `SettingsWindowController.showSettings()` to ensure window comes to front on every call
- [x] 2.2 Wire up "Open History" action in `MenuBarDropdownView` to call `HistoryWindowController.shared.showHistory()`
- [ ] 2.3 Verify both windows come to front when activated from dropdown

## 3. Provider Display Fix

- [x] 3.1 Add `@Query` for active provider in `MenuBarDropdownView`
- [x] 3.2 Replace hardcoded "OpenAI · gpt-4o" text with active provider's `displayName`
- [x] 3.3 Handle case when no provider is active (show "No provider configured")

## 4. Menu Item Text Updates

- [x] 4.1 Change "Open Settings..." to "Settings" in `MenuBarDropdownView`
- [x] 4.2 Change "Open History..." to "History" in `MenuBarDropdownView`

## 5. Remove Retry Last

- [x] 5.1 Remove "Retry Last" `MenuBarRowView` from `utilitySection` in `MenuBarDropdownView`
- [x] 5.2 Remove `retryLast()` method from `AppCoordinator` (if exists)
- [x] 5.3 Remove any related hotkey binding for Retry Last (⌃R)

## 6. Testing & Verification

- [x] 6.1 Build and run the app
- [ ] 6.2 Verify Settings opens and comes to front from dropdown
- [ ] 6.3 Verify History opens and comes to front from dropdown
- [ ] 6.4 Verify provider name displays correctly in dropdown header
- [ ] 6.5 Verify Retry Last is removed from dropdown
- [ ] 6.6 Verify menu item labels are "Settings" and "History"