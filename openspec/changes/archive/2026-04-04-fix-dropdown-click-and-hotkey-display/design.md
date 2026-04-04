## Context

Two bugs in the menu bar dropdown:

1. `togglePopover()` uses a global `NSEvent` monitor to detect outside clicks and close the popover. But clicking the status bar button itself is also an "outside" click from the monitor's perspective. The monitor fires first (closing the popover), then the button action fires (reopening it). Net result: first click appears to do nothing.

2. `hotkeyBadgeText()` hardcodes `"⌃"` prefix and only calls `KeyCodeMapping.stringForKeyCode()`, ignoring `hotkeyModifiers`. The Action model already has `hotkeyDisplayString` that correctly decodes all modifiers.

## Goals / Non-Goals

**Goals:**
- Single click reliably toggles the dropdown open/closed
- Hotkey badges in the dropdown accurately reflect the registered key combination

**Non-Goals:**
- Changing popover behavior, appearance, or animation
- Modifying the Action model or hotkey registration

## Decisions

### Decision 1: Remove event monitor before toggle action fires

**Choice**: In `togglePopover()`, always remove the existing global event monitor at the start of the method before checking `popover.isShown`. This ensures the monitor from a previous open doesn't interfere with the toggle.

**Alternative considered**: Filtering clicks on the status bar button window in the monitor callback. This works but is fragile — it requires comparing `NSEvent.window` with `statusItem.button.window`, which can break if the button window reference changes.

**Alternative considered**: Using `NSPopover.behavior = .transient` instead of a manual event monitor. This auto-closes on outside clicks, but may not work reliably with `NSStatusItem` popovers in all macOS versions.

### Decision 2: Use `action.hotkeyDisplayString` directly

**Choice**: Replace `hotkeyBadgeText()` with `action.hotkeyDisplayString`. The computed property on Action already handles all modifier flags (⌃, ⌥, ⇧, ⌘) and the key code mapping.

**Why**: Eliminates duplication and ensures the dropdown always matches what the model stores. No new code needed — just use what's already there.

## Risks / Trade-offs

**[Risk] Event monitor removal timing** → Removing the monitor at the start of `togglePopover` means there's a brief moment where outside clicks aren't caught. This is negligible since the toggle immediately either shows (and installs a new monitor) or closes the popover.

## Testability

- **Popover toggle**: Manual verification — click status bar button to open, click again to close, verify single-click works
- **Hotkey display**: Unit test `action.hotkeyDisplayString` (already tested in ActionTests). Visual verification in dropdown.
