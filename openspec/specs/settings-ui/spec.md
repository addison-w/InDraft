## ADDED Requirements

### Requirement: Settings window with tabbed navigation
The settings window SHALL have a left sidebar with tabs: General, Actions, Providers, History, Diagnostics. The window title SHALL be "InDraft Settings".

#### Scenario: Open settings
- **WHEN** the user clicks "Settings" in the menu bar dropdown
- **THEN** the settings window opens and comes to front with the previously selected tab (or General on first open)

### Requirement: General settings tab
General tab SHALL include: Launch at Login toggle, Show Dock Icon toggle, appearance preference, and notification behavior settings.

#### Scenario: Toggle launch at login
- **WHEN** the user toggles "Launch at Login"
- **THEN** the login item registration is updated immediately

### Requirement: Actions settings tab
Actions tab SHALL display all actions in a reorderable list. Each action row shows: name, hotkey badge, output behavior badge, enabled toggle, and overflow menu (edit, duplicate, delete). Includes "+ New Action" button and "Restore Defaults" link.

#### Scenario: View actions list
- **WHEN** the user opens Settings > Actions
- **THEN** all actions are listed in sort_order with name, hotkey badge, output behavior badge, and enabled toggle

#### Scenario: Open action editor
- **WHEN** the user clicks an action row or selects "Edit" from overflow menu
- **THEN** the action editor modal/sheet opens with all fields populated

### Requirement: Action editor modal
The action editor SHALL present: name field, prompt textarea, hotkey recorder (with Record/Clear buttons), output behavior selector (Replace/Preview/Clipboard), provider mode selector (Use Active/Fixed Provider), model override field (when fixed), enabled toggle, Cancel and Save Action buttons.

#### Scenario: Edit and save action
- **WHEN** the user modifies fields in the action editor and clicks "Save Action"
- **THEN** all changes are persisted AND hotkey registration is updated AND the modal closes

#### Scenario: Cancel editing
- **WHEN** the user clicks "Cancel" in the action editor
- **THEN** no changes are saved AND the modal closes

### Requirement: Providers settings tab
Providers tab SHALL list all providers. Each provider card shows: display name, base URL, default model, active/test status badges, and actions (Edit, Test, Set Active). Includes "+ Add Provider" button.

#### Scenario: View provider list
- **WHEN** the user opens Settings > Providers
- **THEN** all providers are listed with their status indicators and action buttons

### Requirement: Provider editor
The provider editor SHALL present: display name, base URL, API key (masked with Show toggle), default model, enabled toggle, and Test Connection button.

#### Scenario: Edit provider
- **WHEN** the user clicks "Edit" on a provider
- **THEN** the provider editor opens with all fields populated (API key masked)

### Requirement: History settings tab
History tab SHALL include: retention policy selector (7/30/90 days, unlimited), enable/disable history recording toggle, clear all history button (with confirmation), and privacy note.

#### Scenario: View history settings
- **WHEN** the user opens Settings > History
- **THEN** the tab shows retention selector, recording toggle, clear button, and privacy note: "All history is stored locally on this device. Selected text is sent only to your configured AI provider for processing."

### Requirement: Diagnostics tab
Diagnostics tab SHALL show: Accessibility permission status (granted/not granted), hotkey registration status (count registered), provider connectivity status (connected/disconnected with details), and last error information.

#### Scenario: View diagnostics
- **WHEN** the user opens Settings > Diagnostics
- **THEN** current status is shown for accessibility, hotkeys, and provider connectivity

#### Scenario: Accessibility not granted shown in diagnostics
- **WHEN** Accessibility permission is not granted
- **THEN** the diagnostics tab shows "NOT GRANTED" with a button to open System Settings

### Requirement: Diagnostics shows actionable accessibility status
The diagnostics settings view SHALL provide a direct action to open System Settings when accessibility permission is not granted.

#### Scenario: Open Settings button shown when not granted
- **WHEN** the diagnostics view displays the accessibility card
- **AND** accessibility permission is not granted
- **THEN** an "Open System Settings" button SHALL be visible on the accessibility card
- **AND** tapping the button SHALL open System Settings to the Accessibility pane

#### Scenario: Open Settings button hidden when granted
- **WHEN** the diagnostics view displays the accessibility card
- **AND** accessibility permission is granted
- **THEN** the "Open System Settings" button SHALL NOT be displayed
