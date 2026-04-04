## ADDED Requirements

### Requirement: Preview panel displays original and transformed text
The preview panel SHALL be a floating window showing original text and transformed text side by side, with Reject, Copy, and Accept buttons.

#### Scenario: Preview panel opens for preview-mode action
- **WHEN** a transformation completes for an action with output_behavior=preview
- **THEN** a floating panel appears showing "ORIGINAL" and "TRANSFORMED" columns with the respective text

### Requirement: Accept applies replacement
Clicking "Accept" in the preview panel SHALL trigger the same replacement logic as direct replace mode.

#### Scenario: Accept transformation
- **WHEN** the user clicks "Accept" in the preview panel
- **THEN** the transformed text replaces the selected text in the source app AND the panel closes

### Requirement: Reject dismisses without changes
Clicking "Reject" SHALL dismiss the preview panel with no modifications to the source app.

#### Scenario: Reject transformation
- **WHEN** the user clicks "Reject" in the preview panel
- **THEN** the panel closes AND no text is modified in the source app

### Requirement: Copy sends to clipboard
Clicking "Copy" SHALL copy the transformed text to clipboard without modifying the source app.

#### Scenario: Copy from preview
- **WHEN** the user clicks "Copy" in the preview panel
- **THEN** the transformed text is copied to clipboard AND the panel remains open

### Requirement: Preview panel does not steal focus
The preview panel SHALL appear as a floating window that does not steal focus from the user's active application.

#### Scenario: Panel appears without focus change
- **WHEN** the preview panel opens
- **THEN** the user's previously active app retains focus AND the panel floats above
