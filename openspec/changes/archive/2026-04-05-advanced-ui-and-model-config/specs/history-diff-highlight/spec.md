## ADDED Requirements

### Requirement: Word-level diff highlighting in transformed text
The history record detail view SHALL highlight differences between original and transformed text at the word level in the transformed text column.

#### Scenario: Inserted words highlighted
- **WHEN** a history record is expanded with diff view enabled AND the transformed text contains words not in the original
- **THEN** the inserted words are displayed with a green background tint

#### Scenario: Unchanged words displayed normally
- **WHEN** a history record is expanded with diff view enabled AND the transformed text contains words identical to the original
- **THEN** the unchanged words are displayed in the default text style

#### Scenario: Removed words indicated
- **WHEN** a history record is expanded with diff view enabled AND the original text contains words not in the transformed text
- **THEN** the removed words are shown in the transformed column with red strikethrough and muted color

### Requirement: Diff toggle control
The history record detail view SHALL include a toggle to switch between plain text view and diff view.

#### Scenario: Toggle diff view on
- **WHEN** the user enables the "Show Changes" toggle on a history record
- **THEN** the transformed text column switches from plain text to diff-highlighted view

#### Scenario: Toggle diff view off
- **WHEN** the user disables the "Show Changes" toggle on a history record
- **THEN** the transformed text column shows plain unformatted text

### Requirement: Diff only available for successful transformations
Diff highlighting SHALL only be available for history records with status=success and non-nil transformed text.

#### Scenario: No diff toggle for error records
- **WHEN** a history record has status=error
- **THEN** no "Show Changes" toggle is displayed

### Requirement: Diff performance guard
For texts exceeding 10,000 words, the diff computation SHALL be skipped and the plain text view SHALL be shown with a note indicating the text is too long for diff.

#### Scenario: Large text skips diff
- **WHEN** the user enables diff view on a record where original or transformed text exceeds 10,000 words
- **THEN** the plain text is shown with a note "Text too long for diff comparison"

### Requirement: Diff preserves whitespace and line breaks
The diff algorithm SHALL preserve paragraph structure and line breaks. Diff units SHALL be words (whitespace-separated tokens), not characters or lines.

#### Scenario: Line breaks preserved in diff
- **WHEN** original text has paragraph breaks AND the transformed text preserves them
- **THEN** the diff view maintains the same paragraph structure
