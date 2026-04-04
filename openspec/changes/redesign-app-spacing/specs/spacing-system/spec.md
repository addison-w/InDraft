# Spec: Spacing System

## ADDED Requirements

### Requirement: Spacing Scale Definition
The system SHALL provide a unified spacing scale with the following absolute values:

| Token | Value | Purpose |
|-------|-------|---------|
| xs | 6pt | Micro-spacing (icon gaps, tight inline elements) |
| sm | 12pt | Compact spacing (badge padding, tight groups) |
| md | 20pt | Standard spacing (list item gaps, content padding) |
| lg | 28pt | Comfortable spacing (section padding, card internal) |
| xl | 40pt | Generous spacing (section margins, page padding) |
| xxl | 56pt | Section separation |
| xxxl | 80pt | Major section breaks |

#### Scenario: Developer uses spacing tokens in SwiftUI view
- **WHEN** developer applies `Theme.Spacing.md` to a VStack spacing
- **THEN** the spacing value SHALL be 20pt

#### Scenario: Spacing scale is consistent across all views
- **WHEN** any view in the application uses Theme.Spacing tokens
- **THEN** the values SHALL match the defined scale exactly

### Requirement: Card Internal Padding
The system SHALL provide explicit card padding for consistent container spacing.

#### Scenario: Card padding helper usage
- **WHEN** developer applies `.padding(Theme.cardPadding)` to a view
- **THEN** the view SHALL receive symmetric padding of 24-28pt on all sides

#### Scenario: Card padding in ActionsSettingsView
- **WHEN** the actions list card is rendered
- **THEN** internal content SHALL have minimum 24pt padding on all edges

### Requirement: Section Padding Requirements
All primary content containers SHALL use minimum `xl` (40pt) vertical padding for section separation.

#### Scenario: Settings view section padding
- **WHEN** a settings view renders its content ScrollView
- **THEN** the VStack content SHALL have `.padding(.vertical, Theme.Spacing.xl)` or greater

#### Scenario: List view section padding
- **WHEN** a list view (History, Actions) renders its content
- **THEN** the top and bottom of the content area SHALL have minimum 40pt padding

### Requirement: List Row Spacing Minimum
All list-based views SHALL use minimum `md` (20pt) spacing between rows.

#### Scenario: History list row spacing
- **WHEN** HistoryWindowView displays transformation records
- **THEN** the LazyVStack spacing SHALL be minimum `Theme.Spacing.md` (20pt)

#### Scenario: Actions list row spacing
- **WHEN** ActionsSettingsView displays action rows
- **THEN** the VStack containing rows SHALL have minimum `Theme.Spacing.md` spacing

#### Scenario: MenuBarDropdown item spacing
- **WHEN** the menu bar dropdown renders action items
- **THEN** each item SHALL have minimum 10pt vertical padding