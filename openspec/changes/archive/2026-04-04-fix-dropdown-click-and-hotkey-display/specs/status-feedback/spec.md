## MODIFIED Requirements

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
