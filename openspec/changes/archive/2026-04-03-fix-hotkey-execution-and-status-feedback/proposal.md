## Why

Hotkey-triggered transformations silently fail because: (1) duplicate `ToastType` enum and `ToastManager` class definitions in `ToastManager.swift` and `ToastView.swift` create type conflicts, (2) `ToastView` is never mounted in any view hierarchy so users see no feedback, and (3) the menu bar processing icon is static rather than animated. The result is that pressing a registered hotkey appears to do nothing — the pipeline may execute but the user gets zero visual confirmation.

## What Changes

- **Fix duplicate toast infrastructure**: Consolidate `ToastManager` and `ToastType` into a single canonical implementation; remove the stale `ToastManager.swift` version
- **Mount toast notifications**: Display `ToastView` as a floating overlay near the menu bar so toasts are actually visible to the user
- **Animate processing icon**: Replace the static processing menu bar icon with an animated indicator (e.g., rotating symbol or frame-based animation via `NSTimer`)
- **Enhance dropdown status**: Add a processing progress indicator and contextual status message in the dropdown header
- **Add macOS notification fallback**: Post `NSUserNotification`/`UNUserNotificationCenter` notifications for critical errors when the toast overlay may not be visible

## Capabilities

### New Capabilities
- `toast-notification-overlay`: Floating toast window that renders near the menu bar without stealing focus, displaying success/error/info messages with auto-dismiss
- `provider-api-key-storage`: Fix Settings provider editor to store API keys in Keychain (like onboarding does) instead of saving raw keys as the reference ID
- `text-replace-reliability`: Fix text replacement to verify AX writes, add timing delays to clipboard fallback, prevent toast overlay from stealing focus, and return accurate result status

### Modified Capabilities
- `status-feedback`: Add animated processing icon, mount toast overlay, enhance dropdown status display during processing
- `hotkey-system`: No spec changes — the hotkey registration and execution flow is correct; the issue is downstream feedback visibility

## Impact

- **Files affected**:
  - `InDraft/Services/ToastManager.swift` — remove (duplicate)
  - `InDraft/Views/MenuBar/ToastView.swift` — consolidate as canonical toast implementation
  - `InDraft/App/MenuBarController.swift` — add processing animation, mount toast overlay window
  - `InDraft/Views/MenuBar/MenuBarDropdownView.swift` — enhance processing status display
  - `InDraft/App/AppDelegate.swift` — wire toast overlay window
  - `InDraft/App/InDraftApp.swift` — potentially add toast overlay scene
- **Services affected**: ToastManager, MenuBarController, AppState (no changes needed)
- **Models affected**: None
- **Dependencies**: No new dependencies
- **Risk**: Low — changes are isolated to UI feedback layer; transformation pipeline and data layer are untouched

## Non-goals

- Changing the hotkey registration or execution pipeline (it works correctly)
- Modifying the transformation service, text capture, or text replacement logic
- Adding new action types or provider features
- Changing the data model or persistence layer

## macOS API Constraints

- `NSWindow.Level.floating` for toast overlay (available macOS 10.0+)
- `NSStatusItem` button image animation via `Timer` (macOS 10.0+)
- No macOS 14+ only APIs required

## Rollback Plan

Changes are purely additive UI feedback. Rollback = revert commits. No window management or activation policy changes involved.

## Affected Services & Models

- **Services**: ToastManager (consolidation), MenuBarController (animation + overlay)
- **Models**: None
- **Complexity**: **M** (medium) — multiple UI surfaces but no architectural changes
