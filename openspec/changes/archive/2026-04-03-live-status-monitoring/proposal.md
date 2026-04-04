## Why

Accessibility permission status is only checked once at app startup. If a user grants permission after the app launches, the "needs access" badge and "Open Settings" button remain visible until the app is restarted. Similarly, DiagnosticsSettingsView only checks on appear or manual "Test Now" — it won't update live. The dropdown also shows all actions regardless of enabled state, which clutters the menu with disabled actions that won't trigger.

## What Changes

- Add periodic accessibility permission polling to `AppCoordinator` so `AppState.status` transitions from `permissionRequired` to `idle` when the user grants permission (and re-registers hotkeys)
- Add polling in `DiagnosticsSettingsView` so the accessibility badge updates live while the view is open
- Filter the dropdown action list to only show enabled actions with their hotkeys

## Non-goals

- Polling for other permission types (e.g., input monitoring)
- Adding notification center alerts for permission changes
- Changing the onboarding accessibility step (already polls)
- Polling when the app is in idle state with permission already granted

## Capabilities

### New Capabilities

_None — enhances existing behavior._

### Modified Capabilities

- `status-feedback`: AppState accessibility status updates reactively via polling, not just at startup
- `settings-ui`: Diagnostics accessibility card updates live while visible

## Impact

- **App**: `AppCoordinator.swift` — add polling timer for accessibility status
- **Views**: `DiagnosticsSettingsView.swift` — add onAppear/onDisappear polling timer
- **Views**: `MenuBarDropdownView.swift` — filter actions to enabled only
- **Services affected**: Uses existing `AccessibilityService.isAccessibilityGranted` — no changes
- **Models affected**: None
- **Risk**: Low — polling is lightweight (`AXIsProcessTrusted()` is a fast syscall)
- **Complexity**: S
