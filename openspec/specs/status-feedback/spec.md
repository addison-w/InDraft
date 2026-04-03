## Requirements

### Requirement: Menu bar icon state machine
The menu bar icon SHALL reflect the current app state: idle (default icon), processing (animated spinning icon), success (checkmark, 3s), error (red dot, 10s), permission-required (warning, persistent). The processing state SHALL use an animated icon rather than a static image.

#### Scenario: Icon transitions to processing with animation
- **WHEN** a transformation is triggered
- **THEN** the menu bar icon SHALL change to an animated spinning indicator within 200ms
- **AND** the animation SHALL cycle at approximately 4fps using timer-driven frame rotation
- **AND** the animation SHALL continue until the state transitions away from processing

#### Scenario: Icon animation stops on success
- **WHEN** the app state transitions from processing to success
- **THEN** the spinning animation SHALL stop immediately
- **AND** the icon SHALL change to a checkmark
- **AND** the icon SHALL return to idle after 3 seconds

#### Scenario: Icon animation stops on error
- **WHEN** the app state transitions from processing to error
- **THEN** the spinning animation SHALL stop immediately
- **AND** the icon SHALL change to an error indicator
- **AND** the icon SHALL return to idle after 10 seconds or on next action

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
The app SHALL display toast notifications via a floating overlay near the menu bar for success, error, and fallback events. Toasts SHALL NOT steal focus. The toast overlay SHALL be rendered in a visible window (not just defined as a view).

#### Scenario: Success toast
- **WHEN** a text replacement succeeds
- **THEN** a "Text replaced" toast appears in the floating overlay near the menu bar AND auto-dismisses after 2 seconds

#### Scenario: Error toast with actionable info
- **WHEN** a transformation fails due to invalid API key
- **THEN** a toast shows "API key invalid -- check Settings > Providers" AND auto-dismisses after 5 seconds

#### Scenario: Fallback toast
- **WHEN** replacement falls back to clipboard-only
- **THEN** a toast shows "Result copied to clipboard -- paste manually" AND auto-dismisses after 5 seconds

#### Scenario: Toast does not steal focus
- **WHEN** any toast notification appears
- **THEN** the user's active app retains focus AND the toast appears as a floating overlay

### Requirement: Multiple rapid actions handled correctly
When multiple actions trigger in quick succession, the icon SHALL reflect the most recent state.

#### Scenario: Rapid success then error
- **WHEN** action A succeeds AND action B fails immediately after
- **THEN** the icon shows error state (most recent)

### Requirement: No text selected notification
When a hotkey is pressed with no text selected, the app SHALL show a visible notification via the toast overlay.

#### Scenario: Hotkey with no selection
- **WHEN** the user presses an action hotkey with no text selected
- **THEN** a "No text selected" notification appears in the toast overlay AND no API call is made

### Requirement: Incomplete setup notification on hotkey
When a hotkey is pressed while setup is incomplete, the app SHALL show a visible notification via the toast overlay explaining what's missing rather than failing silently.

#### Scenario: Hotkey pressed without provider
- **WHEN** the user presses an action hotkey with no active provider
- **THEN** a notification shows "No active provider -- configure one in Settings > Providers" in the toast overlay

### Requirement: Permission required state shows actionable guidance
When accessibility permission is not granted, the app SHALL provide a direct action to open System Settings from the menu bar dropdown and from the hotkey error toast. The app SHALL continuously monitor accessibility permission status and update the UI when the user grants permission.

#### Scenario: Dropdown shows Open Settings button when permission not granted
- **WHEN** the app status is `permissionRequired`
- **THEN** the menu bar dropdown SHALL display an "Open Settings" button near the "needs access" badge
- **AND** tapping the button SHALL open System Settings to the Accessibility pane

#### Scenario: Dropdown hides Open Settings button when permission is granted
- **WHEN** the app status is not `permissionRequired`
- **THEN** the menu bar dropdown SHALL NOT display the "Open Settings" button

#### Scenario: Hotkey error toast references dropdown action
- **WHEN** a hotkey is pressed without accessibility permission
- **THEN** the error toast SHALL display "Accessibility permission required -- use the menu bar to open Settings"

#### Scenario: App detects permission granted without restart
- **WHEN** the app is in `permissionRequired` state
- **AND** the user grants accessibility permission in System Settings
- **THEN** the app SHALL detect the change within 2 seconds
- **AND** transition status to `idle`
- **AND** register all hotkeys for enabled actions

#### Scenario: Dropdown only shows enabled actions
- **WHEN** the user opens the menu bar dropdown
- **THEN** only actions with `enabled == true` SHALL be listed
- **AND** each action SHALL display its assigned hotkey badge if one exists

#### Scenario: Single click toggles dropdown
- **WHEN** the user clicks the menu bar status item button
- **THEN** the dropdown SHALL toggle open or closed with a single click
- **AND** clicking the button while the dropdown is open SHALL close it
- **AND** clicking outside the dropdown SHALL close it without requiring an extra click on the button to reopen

#### Scenario: Hotkey badge displays all registered modifiers
- **WHEN** the dropdown displays an action with a registered hotkey
- **THEN** the hotkey badge SHALL display all modifier symbols (⌃ for Control, ⌥ for Option, ⇧ for Shift, ⌘ for Command) followed by the key
- **AND** the display SHALL match the actual registered hotkey combination (e.g., Control+Option+1 displays as "⌃⌥1", not "⌃1")

### Requirement: Dropdown processing status indicator
The menu bar dropdown SHALL display a contextual processing indicator in the header section when a transformation is in progress.

#### Scenario: Dropdown shows processing state
- **WHEN** the user opens the dropdown while a transformation is processing
- **THEN** the header SHALL display a "processing" badge with a subtle pulse or activity indicator
- **AND** the badge SHALL disappear when processing completes

#### Scenario: Dropdown shows idle state
- **WHEN** the user opens the dropdown while no transformation is active
- **THEN** no processing indicator SHALL be displayed in the header

#### Scenario: Dropdown shows error context
- **WHEN** the user opens the dropdown after a transformation error
- **THEN** the header SHALL display an "error" badge
- **AND** the badge SHALL disappear after the error auto-dismiss timeout (10 seconds)
