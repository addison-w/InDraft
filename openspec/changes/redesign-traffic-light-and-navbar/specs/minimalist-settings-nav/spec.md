## ADDED Requirements

### Requirement: Settings navigation uses minimalist tab bar
The Settings navigation SHALL use a text-based tab bar instead of a segmented control, with typographic hierarchy indicating the active tab.

#### Scenario: Settings displays tab bar
- **WHEN** the user opens the Settings window
- **THEN** a horizontal row of text tabs is displayed below the window title
- **AND** the tabs are labeled: General, Providers, Actions, Hotkeys, About
- **AND** the tabs are separated by adequate spacing (24pt)

#### Scenario: Active tab visual state
- **WHEN** a tab is selected
- **THEN** the tab text uses Charcoal color (#2F3430)
- **AND** a 2pt underline in Pale Blue (#D3E5F0) appears below the text
- **AND** the underline animates smoothly (200ms) when switching tabs

#### Scenario: Inactive tab visual state
- **WHEN** a tab is not selected
- **THEN** the tab text uses Light Charcoal color (#787774)
- **AND** no underline is visible
- **AND** on hover, the text opacity increases slightly (to #5A5A58)

#### Scenario: Tab switching
- **WHEN** the user clicks on an inactive tab
- **THEN** the tab becomes the active tab
- **AND** the corresponding settings content is displayed
- **AND** the previous tab becomes inactive

#### Scenario: Tab typography
- **WHEN** viewing the tab bar
- **THEN** all tabs use Inter font, 13pt, medium weight
- **AND** the active tab maintains the same font weight (no bold)
- **AND** the distinction is made through color and underline only

### Requirement: Settings navigation maintains functionality
The redesigned navigation SHALL maintain all existing functionality from the previous segmented control.

#### Scenario: Tab content persistence
- **WHEN** the user switches between tabs
- **THEN** the state of each tab's content is preserved
- **AND** returning to a tab shows the same content as before

#### Scenario: Keyboard navigation
- **WHEN** the user presses Tab or Arrow keys while focused on the tab bar
- **THEN** focus moves between tabs
- **AND** pressing Space or Enter activates the focused tab

#### Scenario: Accessibility labels
- **WHEN** VoiceOver is enabled
- **THEN** each tab announces its label (e.g., "General, tab")
- **AND** the active tab announces its selected state
