## MODIFIED Requirements

### Requirement: Diagnostics shows actionable accessibility status
The diagnostics settings view SHALL provide a direct action to open System Settings when accessibility permission is not granted.

#### Scenario: Open Settings button shown when not granted
- **WHEN** the diagnostics view displays the accessibility card
- **AND** accessibility permission is not granted
- **THEN** an "Open System Settings" button SHALL be visible on the accessibility card
- **AND** tapping the button SHALL open System Settings to the Accessibility pane

#### Scenario: Open Settings button hidden when granted
- **WHEN** the diagnostics view displays the accessibility card
- **AND** accessibility permission is granted
- **THEN** the "Open System Settings" button SHALL NOT be displayed
