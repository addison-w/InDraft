## ADDED Requirements

### Requirement: Global hotkey detection and routing

The system SHALL register global keyboard shortcuts via Carbon Hotkey API and route hotkey presses to their associated actions.

#### Scenario: Hotkey press triggers associated action
- **WHEN** user presses a registered hotkey combination (e.g., Ctrl+Opt+1)
- **THEN** the system SHALL look up the associated action and execute its transformation pipeline

#### Scenario: Hotkey registration on app launch
- **WHEN** the app launches
- **THEN** all enabled actions with configured hotkeys SHALL be registered with the system

#### Scenario: Hotkey deregistration on action disable
- **WHEN** an action is disabled
- **THEN** its hotkey SHALL be deregistered from the system

### Requirement: Hotkey conflict detection

The system SHALL detect and prevent conflicting hotkey registrations.

#### Scenario: Conflicting hotkey combination
- **WHEN** user attempts to register a hotkey combination that is already registered
- **THEN** the system SHALL return an error and not register the duplicate