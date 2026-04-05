### Requirement: Version displayed in menu bar dropdown header
The menu bar dropdown SHALL display the app version string in the header section, right-aligned on the same line as the "InDraft" title, formatted as "v{version}" using monospace tertiary styling.

#### Scenario: Version appears in dropdown header
- **WHEN** the user opens the menu bar dropdown
- **THEN** the header SHALL display the app marketing version (CFBundleShortVersionString) prefixed with "v"
- **AND** the version text SHALL be right-aligned opposite the "InDraft" title
- **AND** the version text SHALL use monospace typography at 9pt in the tertiary text color

#### Scenario: Version string unavailable
- **WHEN** the app version cannot be read from the bundle
- **THEN** the version label SHALL not be displayed (graceful fallback to empty)

### Requirement: Version displayed in settings sidebar footer
The settings window sidebar SHALL display the app version string at the bottom-left, below the navigation tabs, formatted as "v{version}" using monospace tertiary styling.

#### Scenario: Version appears in settings sidebar
- **WHEN** the user opens the settings window
- **THEN** the sidebar footer SHALL display the app marketing version (CFBundleShortVersionString) prefixed with "v"
- **AND** the version text SHALL be anchored to the bottom-left of the sidebar
- **AND** the version text SHALL use monospace typography at 9pt in the tertiary text color

#### Scenario: Version string unavailable in settings
- **WHEN** the app version cannot be read from the bundle
- **THEN** the version label in the settings sidebar SHALL not be displayed

### Requirement: Version string source
The app version SHALL be sourced from `Bundle.main.infoDictionary["CFBundleShortVersionString"]`, which corresponds to the marketing version set in the Xcode project.

#### Scenario: Version matches bundle info
- **WHEN** the app version is displayed in any location
- **THEN** it SHALL exactly match the CFBundleShortVersionString value from the app bundle
