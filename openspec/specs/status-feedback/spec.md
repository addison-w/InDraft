## ADDED Requirements

### Requirement: Menu bar icon state machine
The menu bar icon SHALL reflect the current app state: idle (default icon), processing (animated spinner), success (checkmark, 3s), error (red dot, 10s), permission-required (warning, persistent).

#### Scenario: Icon transitions to processing
- **WHEN** a transformation is triggered
- **THEN** the menu bar icon changes to processing state within 200ms

#### Scenario: Icon shows success
- **WHEN** a transformation completes successfully
- **THEN** the icon changes to success state AND returns to idle after 3 seconds

#### Scenario: Icon shows error
- **WHEN** a transformation fails
- **THEN** the icon changes to error state AND returns to idle after 10 seconds or on next action

#### Scenario: Icon shows permission required
- **WHEN** the app detects missing Accessibility permission
- **THEN** the icon shows warning state AND remains in that state until the permission is granted

### Requirement: Toast notifications for feedback
The app SHALL display toast notifications near the menu bar for success, error, and fallback events. Toasts SHALL NOT steal focus.

#### Scenario: Success toast
- **WHEN** a text replacement succeeds
- **THEN** a "Text replaced" toast appears near the menu bar AND auto-dismisses after 2 seconds

#### Scenario: Error toast with actionable info
- **WHEN** a transformation fails due to invalid API key
- **THEN** a toast shows "API key invalid — check Settings > Providers" AND auto-dismisses after 5 seconds

#### Scenario: Fallback toast
- **WHEN** replacement falls back to clipboard-only
- **THEN** a toast shows "Result copied to clipboard — paste manually" AND auto-dismisses after 5 seconds

#### Scenario: Toast does not steal focus
- **WHEN** any toast notification appears
- **THEN** the user's active app retains focus AND the toast appears as an overlay

### Requirement: Multiple rapid actions handled correctly
When multiple actions trigger in quick succession, the icon SHALL reflect the most recent state.

#### Scenario: Rapid success then error
- **WHEN** action A succeeds AND action B fails immediately after
- **THEN** the icon shows error state (most recent)

### Requirement: No text selected notification
When a hotkey is pressed with no text selected, the app SHALL show a notification.

#### Scenario: Hotkey with no selection
- **WHEN** the user presses an action hotkey with no text selected
- **THEN** a "No text selected" notification appears AND no API call is made

### Requirement: Incomplete setup notification on hotkey
When a hotkey is pressed while setup is incomplete, the app SHALL show a notification explaining what's missing rather than failing silently.

#### Scenario: Hotkey pressed without provider
- **WHEN** the user presses an action hotkey with no active provider
- **THEN** a notification shows "No active provider — configure one in Settings > Providers"

### Requirement: Permission required state shows actionable guidance
When accessibility permission is not granted, the app SHALL provide a direct action to open System Settings from the menu bar dropdown and from the hotkey error toast.

#### Scenario: Dropdown shows Open Settings button when permission not granted
- **WHEN** the app status is `permissionRequired`
- **THEN** the menu bar dropdown SHALL display an "Open Settings" button near the "needs access" badge
- **AND** tapping the button SHALL open System Settings to the Accessibility pane

#### Scenario: Dropdown hides Open Settings button when permission is granted
- **WHEN** the app status is not `permissionRequired`
- **THEN** the menu bar dropdown SHALL NOT display the "Open Settings" button

#### Scenario: Hotkey error toast references dropdown action
- **WHEN** a hotkey is pressed without accessibility permission
- **THEN** the error toast SHALL display "Accessibility permission required — use the menu bar to open Settings"
