## MODIFIED Requirements

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
