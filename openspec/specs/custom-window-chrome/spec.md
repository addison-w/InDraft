## ADDED Requirements

### Requirement: Settings window displays custom window chrome
The Settings window SHALL display custom window controls (close, minimize, zoom) instead of system traffic lights, using the app's warm monochrome design language.

#### Scenario: Settings window opens with custom chrome
- **WHEN** the user opens the Settings window
- **THEN** the window displays three circular window controls (close, minimize, zoom) in the top-left corner
- **AND** the controls use subtle gray color (#E8E8E8) in default state
- **AND** the system traffic lights are not visible

#### Scenario: Close button hover state
- **WHEN** the user hovers over the close button
- **THEN** the button changes to red color (#FF5F57)
- **AND** an X icon (SF Symbol xmark) appears

#### Scenario: Minimize button hover state
- **WHEN** the user hovers over the minimize button
- **THEN** the button changes to yellow color (#FFBD2E)
- **AND** a minus icon (SF Symbol minus) appears

#### Scenario: Zoom button hover state
- **WHEN** the user hovers over the zoom button
- **THEN** the button changes to green color (#28C840)
- **AND** a fullscreen icon (SF Symbol arrow.up.left.and.arrow.down.right) appears

#### Scenario: Close button click action
- **WHEN** the user clicks the close button
- **THEN** the Settings window closes
- **AND** the app remains running (LSUIElement behavior unchanged)

#### Scenario: Minimize button click action
- **WHEN** the user clicks the minimize button
- **THEN** the Settings window minimizes to the Dock

#### Scenario: Zoom button click action
- **WHEN** the user clicks the zoom button
- **THEN** the Settings window enters/exits full-screen mode

### Requirement: History window displays custom window chrome
The History window SHALL display the same custom window controls as the Settings window, maintaining visual consistency.

#### Scenario: History window opens with custom chrome
- **WHEN** the user opens the History window
- **THEN** the window displays the same three custom circular controls
- **AND** the controls have identical styling and behavior to Settings window

#### Scenario: History window close action
- **WHEN** the user clicks the close button on History window
- **THEN** the History window closes
- **AND** the app continues running normally

### Requirement: Custom chrome maintains accessibility
The custom window controls SHALL remain accessible to assistive technologies.

#### Scenario: VoiceOver identifies window controls
- **WHEN** VoiceOver is enabled
- **THEN** each window control has an accessible label ("Close", "Minimize", "Enter Full Screen")
- **AND** the controls are reachable via keyboard navigation

#### Scenario: Keyboard shortcuts remain functional
- **WHEN** the user presses Cmd+W
- **THEN** the active window closes
- **AND** when the user presses Cmd+M
- **THEN** the active window minimizes
