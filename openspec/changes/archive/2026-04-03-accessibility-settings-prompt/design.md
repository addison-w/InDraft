## Context

InDraft already has full accessibility permission infrastructure:
- `AccessibilityService.openAccessibilitySettings()` opens System Settings to the Accessibility pane via `x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility`
- `AccessibilityStepView` (onboarding) has an "Open System Settings" button and 1-second polling
- `AppState.permissionRequired` state drives the warning triangle icon and "needs access" badge

The gap: after onboarding, no UI surface provides a direct "Open System Settings" button. The dropdown shows a badge, diagnostics shows a status, and the toast gives a text-only message.

## Goals / Non-Goals

**Goals:**
- Add "Open System Settings" button to the menu bar dropdown when `permissionRequired`
- Add "Open System Settings" button to the diagnostics accessibility card when not granted
- Make the hotkey error toast more helpful

**Non-Goals:**
- Adding permission polling outside onboarding
- Creating new windows or modals
- Changing `AccessibilityService` protocol or implementation
- Modifying `AppState` or `AppCoordinator` state management

## Decisions

### Decision 1: Inline button in dropdown header area

**Choice**: Add a small "Open Settings" button directly below the "needs access" badge in the dropdown, visible only when `appState.status == .permissionRequired`.

**Rationale**: The dropdown is the primary interaction surface — users see the "needs access" badge and need an immediate action. A button here provides the shortest path. The button calls `AccessibilityService.openAccessibilitySettings()` which already exists.

**Alternative considered**: A separate banner/callout view in the dropdown. Rejected as too heavy for a transient popover — a single button is sufficient.

### Decision 2: Button in diagnostics card

**Choice**: Add a "Open System Settings" button to the right side of the accessibility diagnostic card, shown only when `accessibilityGranted` is false.

**Rationale**: Users directed to diagnostics should be able to act immediately rather than manually navigating to System Settings. Follows the same pattern as the onboarding step.

### Decision 3: Update toast message text

**Choice**: Change the hotkey error toast from "Accessibility permission required — check Settings > Diagnostics" to "Accessibility permission required — use the menu bar to open Settings".

**Rationale**: Points users to the new dropdown button rather than a multi-step navigation path through settings.

## Testability

- **Unit test**: Verify `AccessibilityService.openAccessibilitySettings()` constructs the correct URL (already tested implicitly)
- **Visual verification**: Build app, revoke accessibility permission, verify button appears in dropdown and diagnostics, verify it opens correct System Settings pane

## Risks / Trade-offs

- **[Low] URL scheme stability**: `x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility` has been stable since macOS 10.14. If Apple changes it, it fails silently (no crash), and the existing onboarding view would also be affected — single fix point.
