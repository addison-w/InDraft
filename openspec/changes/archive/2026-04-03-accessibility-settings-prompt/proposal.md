## Why

When accessibility permission is not granted after onboarding, users have no direct way to fix it from the main app. The menu bar dropdown shows a "needs access" badge and hotkey presses show an error toast saying "check Settings > Diagnostics", but neither provides a one-click path to System Settings > Accessibility. Users must manually navigate there, which is friction that prevents them from using the app.

## What Changes

- Add an "Open System Settings" button to the menu bar dropdown when accessibility is not granted, providing a one-click path to the Accessibility pane
- Add an "Open System Settings" button to the Diagnostics settings view when accessibility shows "NOT GRANTED"
- Update the hotkey error toast to be more actionable (direct user to the dropdown button rather than a generic Settings reference)

## Non-goals

- Changing the onboarding accessibility step (already has an "Open System Settings" button)
- Adding a persistent modal or alert — keep it non-intrusive
- Polling for permission changes outside of onboarding
- Changing the AccessibilityService protocol interface

## Capabilities

### New Capabilities

_None — this enhances existing UI surfaces._

### Modified Capabilities

- `status-feedback`: Add actionable "Open System Settings" affordance when accessibility is not granted in dropdown and diagnostics
- `settings-ui`: Add "Open System Settings" button to diagnostics accessibility card when not granted

## Impact

- **Views**: `MenuBarDropdownView.swift` (add button), `DiagnosticsSettingsView.swift` (add button)
- **App**: `AppCoordinator.swift` (update toast message)
- **Services affected**: Uses existing `AccessibilityService.openAccessibilitySettings()` — no service changes needed
- **Models affected**: None
- **Risk**: Low — additive UI changes only, no state or service modifications
- **Complexity**: S
