## MODIFIED Requirements

### Requirement: Diagnostics shows actionable accessibility status
The diagnostics settings view SHALL provide a direct action to open System Settings when accessibility permission is not granted. The accessibility status SHALL update live while the diagnostics view is visible.

#### Scenario: Open Settings button shown when not granted
- **WHEN** the diagnostics view displays the accessibility card
- **AND** accessibility permission is not granted
- **THEN** an "Open System Settings" button SHALL be visible on the accessibility card
- **AND** tapping the button SHALL open System Settings to the Accessibility pane

#### Scenario: Open Settings button hidden when granted
- **WHEN** the diagnostics view displays the accessibility card
- **AND** accessibility permission is granted
- **THEN** the "Open System Settings" button SHALL NOT be displayed

#### Scenario: Diagnostics updates live when permission changes
- **WHEN** the diagnostics view is visible
- **AND** the user grants or revokes accessibility permission in System Settings
- **THEN** the accessibility status badge SHALL update within 2 seconds without manual interaction
