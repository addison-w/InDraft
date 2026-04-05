## MODIFIED Requirements

### Requirement: Settings tab navigation icons
The settings view SHALL display Hugeicons icons for each tab (General, Actions, Providers, History) instead of SF Symbols.

#### Scenario: Settings tabs display correct icons
- **WHEN** the settings window is opened
- **THEN** each tab (General, Actions, Providers, History) SHALL display its corresponding Hugeicons icon via `AppIcon`

### Requirement: Actions list UI icons
The actions settings view SHALL use Hugeicons for the drag handle, expand/collapse chevron, and add button.

#### Scenario: Actions list icons render correctly
- **WHEN** the actions settings view is displayed
- **THEN** the drag handle, chevron indicators, and add button SHALL use `AppIcon` views

### Requirement: Providers list UI icons
The providers settings view SHALL use Hugeicons for the eye/eye-slash toggle, add button, chevron, and connection test result icons.

#### Scenario: Password visibility toggle icons
- **WHEN** the user toggles API key visibility in providers settings
- **THEN** the toggle SHALL display `AppIcon.eye` (visible) or `AppIcon.eyeSlash` (hidden)

#### Scenario: Provider connection test result icons
- **WHEN** a provider connection test succeeds or fails
- **THEN** the result SHALL display `AppIcon.success` (checkmark) or `AppIcon.error` (xmark circle)

### Requirement: History settings privacy icon
The history settings view SHALL use a Hugeicons icon for the privacy note.

#### Scenario: Privacy note icon
- **WHEN** the history settings view is displayed
- **THEN** the privacy note SHALL display `AppIcon` equivalent of the lock-shield icon
