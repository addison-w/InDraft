# Spec: Settings UI (Delta)

## MODIFIED Requirements

### Requirement: Settings View Layout
The settings view SHALL display a navigation sidebar on the left and content detail on the right, with improved spacing and proportions.

#### Scenario: Sidebar width and spacing
- **WHEN** the settings window is displayed
- **THEN** the sidebar SHALL have minimum width of 180pt (increased from 140pt)
- **AND** sidebar items SHALL have `Theme.Spacing.lg` (28pt) horizontal padding
- **AND** sidebar items SHALL have `Theme.Spacing.md` (20pt) vertical padding

#### Scenario: Content area padding
- **WHEN** a settings tab content is displayed
- **THEN** the ScrollView content SHALL have `.padding(Theme.Spacing.xl)` (40pt) on all edges

#### Scenario: Header row spacing
- **WHEN** a settings view displays a header section
- **THEN** the header SHALL have minimum `Theme.Spacing.xl` (40pt) bottom padding before content

### Requirement: Action Row Layout
The action row in ActionsSettingsView SHALL have generous internal padding for comfortable interaction.

#### Scenario: Action row internal spacing
- **WHEN** an action row is rendered
- **THEN** the row SHALL have `.padding(.horizontal, Theme.Spacing.xl)` (40pt horizontal)
- **AND** the row SHALL have `.padding(.vertical, Theme.Spacing.lg)` (28pt vertical)

#### Scenario: Action row content spacing
- **WHEN** action details (name, hotkey badge, status) are displayed
- **THEN** the VStack containing them SHALL have `Theme.Spacing.md` (20pt) spacing

#### Scenario: Action list card padding
- **WHEN** the actions list card is displayed
- **THEN** the internal content SHALL have `Theme.cardPadding` (24-28pt symmetric)

## ADDED Requirements

### Requirement: Bottom Bar Spacing
The bottom bar in settings views SHALL have adequate separation from content.

#### Scenario: Bottom bar top margin
- **WHEN** a settings view displays a bottom action bar (e.g., "New Action", "Restore Defaults")
- **THEN** the bar SHALL have minimum `Theme.Spacing.xl` (40pt) top padding separation from content