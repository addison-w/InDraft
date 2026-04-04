## ADDED Requirements

### Requirement: History record data model
Each history record SHALL store: id, timestamp, source_app, action_id, action_name, provider_id, provider_name, model_name, original_text, transformed_text, latency_ms, status (success|error), error_code (nullable), error_message (nullable).

#### Scenario: Successful transformation recorded
- **WHEN** a transformation completes successfully
- **THEN** a history record is created with status=success, all text fields, latency, and snapshot of action/provider names

#### Scenario: Failed transformation recorded
- **WHEN** a transformation fails at any stage (capture, API, replacement)
- **THEN** a history record is created with status=error, error_code identifying the failure stage, and error_message with details

### Requirement: History stores name snapshots
action_name and provider_name SHALL be stored as snapshots (copies), not just foreign key references. History SHALL remain readable after actions or providers are deleted.

#### Scenario: History readable after action deletion
- **WHEN** an action is deleted
- **THEN** all history records for that action still display the action name correctly

### Requirement: History window with search and filtering
The history window SHALL display records in reverse chronological order with search across action name, source app, original text, and transformed text.

#### Scenario: Search history
- **WHEN** the user types a search query in the history search field
- **THEN** the list filters to records matching the query across action name, source app, original text, and transformed text

#### Scenario: Expand history record
- **WHEN** the user clicks on a history record
- **THEN** the record expands to show full original text and transformed text side by side

### Requirement: History record actions
Users SHALL be able to copy original text, copy transformed text, retry (re-run same action on original text), and delete individual records.

#### Scenario: Copy original text from history
- **WHEN** the user clicks "Copy Original" on a history record
- **THEN** the original text is copied to the clipboard

#### Scenario: Copy transformed text from history
- **WHEN** the user clicks "Copy Result" on a history record
- **THEN** the transformed text is copied to the clipboard

#### Scenario: Retry from history
- **WHEN** the user clicks "Retry" on a history record
- **THEN** the same action prompt is run against the original text using the current provider configuration

#### Scenario: Delete history record
- **WHEN** the user clicks "Delete" on a history record
- **THEN** the record is permanently removed

### Requirement: Clear all history
Users SHALL be able to clear all history with confirmation.

#### Scenario: Clear all history
- **WHEN** the user clicks "Clear All" AND confirms
- **THEN** all history records are permanently deleted

### Requirement: Configurable retention policy
History retention SHALL be configurable: 7, 30, 90 days, or unlimited. Default is 30 days. Records older than the retention period SHALL be auto-deleted on app launch.

#### Scenario: Auto-prune on launch
- **WHEN** the app launches with 30-day retention AND records exist older than 30 days
- **THEN** the old records are automatically deleted

#### Scenario: Change retention period
- **WHEN** the user changes retention from 30 days to 7 days
- **THEN** the new retention period takes effect on next app launch

### Requirement: History recording toggle
Users SHALL be able to disable history recording entirely in Settings > History.

#### Scenario: Disable history recording
- **WHEN** the user disables history recording
- **THEN** no new history records are created for transformations AND existing records are preserved

### Requirement: Retry Last action from menu bar
The menu bar dropdown SHALL include a "Retry Last" item that re-runs the most recent transformation on the current selection.

#### Scenario: Retry Last with text selected
- **WHEN** the user clicks "Retry Last" with text selected
- **THEN** the most recent action is re-run on the currently selected text

#### Scenario: Retry Last with no selection
- **WHEN** the user clicks "Retry Last" with no text selected
- **THEN** a "No text selected" notification is shown

#### Scenario: Retry Last with empty history
- **WHEN** history is empty
- **THEN** "Retry Last" is greyed out and disabled in the dropdown
