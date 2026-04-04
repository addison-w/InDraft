## Why

Two UX bugs in the menu bar dropdown degrade the experience:

1. **Double-click required to open dropdown**: The global event monitor that closes the popover on outside clicks also fires when clicking the status bar button itself. This causes the popover to close (via monitor) then immediately reopen (via `togglePopover`), making it appear unresponsive on first click.

2. **Hotkey badges show wrong modifiers**: `hotkeyBadgeText()` in `MenuBarDropdownView` hardcodes `"⌃"` (Control only) and ignores the actual modifier flags. Default actions use Control+Option (⌃⌥), so badges show `⌃1` instead of `⌃⌥1`.

## What Changes

- **Fix popover toggle**: Filter clicks on the status bar button from the global event monitor, or remove the monitor before the toggle action fires, so a single click reliably opens/closes the dropdown
- **Fix hotkey badge text**: Replace the hardcoded `hotkeyBadgeText()` with `action.hotkeyDisplayString` which already correctly reads all modifier flags from the Action model

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `status-feedback`: Fix dropdown toggle behavior and hotkey badge display accuracy

## Impact

- **Files affected**:
  - `InDraft/App/MenuBarController.swift` — fix `togglePopover()` and event monitor logic
  - `InDraft/Views/MenuBar/MenuBarDropdownView.swift` — replace `hotkeyBadgeText()` with `action.hotkeyDisplayString`
- **Services affected**: None
- **Models affected**: None (Action.hotkeyDisplayString already works correctly)
- **Risk**: Very low — two isolated UI fixes

## Non-goals

- Changing the popover appearance or animation
- Modifying hotkey registration or the Action model
- Adding new dropdown features

## Complexity: **S** (small)
