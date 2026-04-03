## ADDED Requirements

### Requirement: App runs as menu bar background process
The app SHALL run as an LSUIElement (no dock icon by default) with a persistent menu bar icon. The app SHALL have no main window — all interaction happens via menu bar dropdown, settings window, history window, and floating preview panel.

#### Scenario: App launches as background process
- **WHEN** the user launches InDraft
- **THEN** a menu bar icon appears in the system menu bar AND no dock icon is shown AND no main window opens

#### Scenario: First launch triggers onboarding
- **WHEN** the user launches InDraft for the first time (no completed onboarding)
- **THEN** the onboarding window opens automatically

#### Scenario: Subsequent launch with completed setup
- **WHEN** the user launches InDraft with completed onboarding and valid provider
- **THEN** the app enters idle state with menu bar icon showing ready status

### Requirement: Dock icon is toggleable
The app SHALL allow the user to toggle dock icon visibility in Settings > General. When enabled, the app appears in the dock and Cmd+Tab switcher.

#### Scenario: Enable dock icon
- **WHEN** the user enables "Show Dock Icon" in Settings > General
- **THEN** the app icon appears in the dock immediately without restart

#### Scenario: Disable dock icon
- **WHEN** the user disables "Show Dock Icon" in Settings > General
- **THEN** the app icon is removed from the dock immediately without restart

### Requirement: Launch at login
The app SHALL support automatic launch at login, configurable in Settings > General. This SHALL use SMAppService (macOS 13+) for login item registration.

#### Scenario: Enable launch at login
- **WHEN** the user enables "Launch at Login" in Settings > General
- **THEN** the app registers as a login item and launches automatically on next login

#### Scenario: Disable launch at login
- **WHEN** the user disables "Launch at Login" in Settings > General
- **THEN** the app unregisters as a login item

### Requirement: Menu bar dropdown displays app state
The menu bar dropdown SHALL show: active provider name, list of enabled actions with hotkeys, Settings, History, and Quit InDraft.

#### Scenario: Dropdown shows active provider
- **WHEN** the user clicks the menu bar icon with a configured active provider
- **THEN** the dropdown header shows "INDRAFT" with the provider name (e.g., "Claude" or "OpenAI")

#### Scenario: Dropdown lists enabled actions
- **WHEN** the user opens the dropdown with 3 default actions enabled
- **THEN** the dropdown shows "Rewrite for Clarity", "Grammar Fix", and "Paraphrase" with their hotkey badges

#### Scenario: Dropdown with no active provider
- **WHEN** the user opens the dropdown with no active provider configured
- **THEN** the dropdown shows a warning message "No AI provider configured — click to set up"

### Requirement: History window accessible from dropdown
The history window SHALL be accessible from the menu bar dropdown. Clicking "History" in the dropdown SHALL open the history window and bring it to front.

#### Scenario: Open history from dropdown
- **WHEN** the user clicks "History" in the menu bar dropdown
- **THEN** the history window opens and comes to front

#### Scenario: History window already open
- **WHEN** the user clicks "History" in the dropdown AND the history window is already open
- **THEN** the existing history window is brought to front and made key

### Requirement: App handles incomplete setup gracefully
When required setup is incomplete, the app SHALL display a warning state in the menu bar and provide direct links to resolve the issue.

#### Scenario: Missing accessibility permission
- **WHEN** the app launches without Accessibility permission
- **THEN** the menu bar icon shows a warning overlay AND the dropdown shows "Accessibility permission required — click to fix"

#### Scenario: No provider configured
- **WHEN** the app launches with no provider configured
- **THEN** the menu bar icon shows a warning overlay AND the dropdown shows "No AI provider configured — click to set up"

### Requirement: Serial transformation queue
The app SHALL process transformation requests serially. Only one transformation SHALL execute at a time. Additional hotkey presses during processing SHALL be queued.

#### Scenario: Hotkey pressed during active transformation
- **WHEN** a transformation is in progress AND the user presses another action hotkey
- **THEN** the second request is queued and executes after the first completes
