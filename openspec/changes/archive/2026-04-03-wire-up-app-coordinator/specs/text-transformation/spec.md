## ADDED Requirements

### Requirement: End-to-end text transformation pipeline

The system SHALL execute the complete text transformation flow: capture → transform → replace.

#### Scenario: Successful transformation with replace output behavior
- **WHEN** user triggers an action with output behavior set to "replace"
- **THEN** the system SHALL capture selected text, send to AI provider, and replace the selection with transformed text

#### Scenario: Successful transformation with preview output behavior
- **WHEN** user triggers an action with output behavior set to "preview"
- **THEN** the system SHALL capture selected text, send to AI provider, and display a preview panel before replacement

#### Scenario: Successful transformation with clipboard output behavior
- **WHEN** user triggers an action with output behavior set to "clipboard"
- **THEN** the system SHALL capture selected text, send to AI provider, and copy result to clipboard

### Requirement: Error handling in transformation

The system SHALL handle errors gracefully and display user-friendly feedback.

#### Scenario: No text selected
- **WHEN** user triggers an action but no text is selected
- **THEN** the system SHALL display an info toast "No text selected"

#### Scenario: No active provider configured
- **WHEN** user triggers an action but no provider is active
- **THEN** the system SHALL display an error toast "No active provider — configure one in Settings > Providers"

#### Scenario: API key missing
- **WHEN** user triggers an action but API key is not stored
- **THEN** the system SHALL display an error toast "API key not found — check Settings > Providers"

#### Scenario: Accessibility permission not granted
- **WHEN** user triggers an action but accessibility is not permitted
- **THEN** the system SHALL display an error toast "Accessibility permission required — check Settings > Diagnostics"