## 1. Fix Dropdown Single-Click Toggle

- [x] 1.1 In `MenuBarController.togglePopover()`, remove the existing global event monitor at the start of the method before checking `popover.isShown`
- [x] 1.2 Verify single-click opens and closes the dropdown reliably

## 2. Fix Hotkey Badge Display

- [x] 2.1 In `MenuBarDropdownView`, replace `hotkeyBadgeText(action)` call with `action.hotkeyDisplayString` in the action list section
- [x] 2.2 Remove the unused `hotkeyBadgeText(_:)` method
- [x] 2.3 Verify dropdown shows correct modifier symbols (e.g., ⌃⌥1 for Control+Option+1)

## 3. Verification

- [x] 3.1 Build the project and confirm no compilation errors
- [x] 3.2 Run existing unit tests to confirm no regressions
