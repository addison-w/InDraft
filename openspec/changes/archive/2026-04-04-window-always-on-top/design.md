## Context

InDraft is an LSUIElement app (activation policy `.accessory`) with no dock icon. It manages three windows via dedicated controllers: `OnboardingWindowController`, `SettingsWindowController`, and `HistoryWindowController`. Each controller already uses `orderFrontRegardless()` and `NSApp.activate()` to bring windows to front on initial show. However, once a window is visible and the user switches to another app, the InDraft window drops behind and cannot be recovered -- there is no dock icon to click, no Cmd+Tab entry, and no window menu to select.

The fix is to set `window.level = .floating` on each window after creation. This places windows at the floating window level (above normal windows but below modal panels and alerts from other apps), ensuring they remain visible regardless of which app is focused.

## Goals / Non-Goals

**Goals:**
- All three window controllers set their window level to `.floating` so windows persist above normal application windows
- Existing `orderFrontRegardless()` and `NSApp.activate()` behavior is preserved unchanged
- The app remains an LSUIElement with `.accessory` activation policy

**Non-Goals:**
- Creating new protocols or services for window management
- Adding a user preference to toggle floating behavior
- Modifying AppCoordinator window lifecycle logic
- Changing any SwiftUI views or AppKit/SwiftUI bridging

## Decisions

### 1. Use `NSWindow.Level.floating` rather than a custom level

**Decision**: Set `window.level = .floating` using the built-in floating level constant.

**Rationale**: `.floating` (level 3) is the standard macOS level for utility/palette windows that should stay above normal windows. It is below `.modalPanel` and `.statusBar`, so it will not interfere with system UI or modal dialogs from other apps. This is the idiomatic choice for utility apps without dock presence.

**Alternative considered**: Using a custom `NSWindow.Level(rawValue:)` -- rejected because `.floating` already provides the exact semantics needed, and custom levels risk conflicts with system window ordering.

### 2. Set window level immediately after window creation in each controller

**Decision**: Add `window.level = .floating` in the same method where the window is created and configured (alongside existing `orderFrontRegardless()` calls).

**Rationale**: Setting the level at creation time ensures the window is always floating from the moment it appears. There is no need for a separate method or lifecycle hook.

**Alternative considered**: Setting level in AppCoordinator -- rejected because window configuration belongs in the window controller, keeping the responsibility close to the window itself.

### 3. No changes to AppCoordinator

**Decision**: All changes are scoped to the three window controller files. AppCoordinator is not modified.

**Rationale**: AppCoordinator owns the lifecycle (create/show/close) of window controllers but does not configure window properties. Adding window level configuration to AppCoordinator would break the existing separation of concerns where controllers own their window setup.

## Testability

- **Manual verification**: Open each window from the menu bar dropdown, switch to another application (e.g., Finder or Safari), and confirm the InDraft window remains visible above the other app's windows.
- **Automated verification**: Build the project to confirm compilation succeeds. The change is a single property assignment per controller and does not introduce testable logic that warrants a new unit test.
- **Regression check**: Verify onboarding flow, settings navigation, and history browsing all function normally with floating windows. Confirm the app activation policy remains `.accessory`.

## Risks / Trade-offs

- **[Risk] Floating windows may obscure content the user is trying to read** -- Mitigation: This is expected and desired behavior for a dock-less utility app. Users can close the window when done. The app already behaves as a floating utility (toast notifications, menu bar popover). If user feedback indicates annoyance, a future change can add a preference toggle.
- **[Risk] Multiple floating InDraft windows could stack awkwardly** -- Mitigation: In practice, only one window is typically open at a time (Settings or History, not both). Onboarding only appears on first launch. The windows are independently closable.

## AppKit/SwiftUI Bridging

No new bridging required. The change is purely at the AppKit NSWindow level, within existing window controller classes that already host SwiftUI content.

## Open Questions

None -- this is a straightforward, well-understood change.
