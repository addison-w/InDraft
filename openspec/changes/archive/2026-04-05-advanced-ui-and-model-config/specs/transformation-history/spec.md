## MODIFIED Requirements

### Requirement: History window with search and filtering
The history window SHALL display records in reverse chronological order with search across action name, source app, original text, and transformed text. Each text section in the expanded detail view SHALL have a maximum height with independent scrolling. The transformed text section SHALL support diff highlighting against the original text.

#### Scenario: Search history
- **WHEN** the user types a search query in the history search field
- **THEN** the list filters to records matching the query across action name, source app, original text, and transformed text

#### Scenario: Expand history record
- **WHEN** the user clicks on a history record
- **THEN** the record expands to show full original text and transformed text side by side, with each text section independently scrollable if content exceeds the max height

#### Scenario: Diff highlighting in expanded record
- **WHEN** the user expands a successful history record with the "Show Changes" toggle enabled
- **THEN** the transformed text column highlights word-level differences compared to the original text
