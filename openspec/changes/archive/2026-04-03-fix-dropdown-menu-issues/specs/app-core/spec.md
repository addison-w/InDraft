## MODIFIED Requirements

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

### Requirement: App runs as menu bar background process
The app SHALL run as an LSUIElement (no dock icon by default) with a persistent menu bar icon. The app SHALL have no main window — all interaction happens via menu bar dropdown, settings window, history window, and floating preview panel.

#### Scenario: Subsequent launch with completed setup
- **WHEN** the user launches InDraft with completed onboarding and valid provider
- **THEN** the app enters idle state with menu bar icon showing ready status

## ADDED Requirements

### Requirement: History window accessible from dropdown
The history window SHALL be accessible from the menu bar dropdown. Clicking "History" in the dropdown SHALL open the history window and bring it to front.

#### Scenario: Open history from dropdown
- **WHEN** the user clicks "History" in the menu bar dropdown
- **THEN** the history window opens and comes to front

#### Scenario: History window already open
- **WHEN** the user clicks "History" in the dropdown AND the history window is already open
- **THEN** the existing history window is brought to front and made key