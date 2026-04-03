## ADDED Requirements

### Requirement: Menu bar action click triggers transformation

The system SHALL allow users to trigger text transformations by clicking action rows in the menu bar dropdown.

#### Scenario: Click action row in dropdown
- **WHEN** user clicks an action row in the menu bar dropdown
- **THEN** the system SHALL dismiss the dropdown and execute the transformation for that action

#### Scenario: Click "Retry Last" in dropdown
- **WHEN** user clicks "Retry Last" in the menu bar dropdown
- **THEN** the system SHALL re-execute the most recent transformation with the same selected text

### Requirement: Menu bar icon reflects processing state

The system SHALL update the menu bar icon to indicate current transformation status.

#### Scenario: Icon shows processing state
- **WHEN** a transformation is in progress
- **THEN** the menu bar icon SHALL change to a processing indicator

#### Scenario: Icon shows success state
- **WHEN** a transformation completes successfully
- **THEN** the menu bar icon SHALL briefly show a checkmark before returning to idle

#### Scenario: Icon shows error state
- **WHEN** a transformation fails
- **THEN** the menu bar icon SHALL show an error indicator until dismissed