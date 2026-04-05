## ADDED Requirements

### Requirement: History detail text sections have max height
Each text section (original and transformed) in the history record detail view SHALL have a maximum height. When text content exceeds this height, the section SHALL become independently scrollable.

#### Scenario: Short text displays without scrollbar
- **WHEN** a history record is expanded AND the original text is under 15 lines
- **THEN** the text section displays at its natural height without a scrollbar

#### Scenario: Long text triggers scroll
- **WHEN** a history record is expanded AND the original text exceeds the max height
- **THEN** the text section is capped at the max height AND a scroll indicator appears AND the user can scroll within the section

#### Scenario: Both columns scroll independently
- **WHEN** a history record has long text in both original and transformed columns
- **THEN** each column scrolls independently of the other

### Requirement: Scroll containment does not affect list layout
The history list layout SHALL NOT be disrupted by long text in expanded records. Other history records SHALL remain accessible without excessive scrolling of the main list.

#### Scenario: List remains navigable with expanded long record
- **WHEN** a history record with very long text is expanded
- **THEN** the expanded record does not push subsequent records more than ~300px below the expand point AND the user can still scroll the main list to reach other records
