## MODIFIED Requirements

### Requirement: Settings window with tabbed navigation
The settings window SHALL have a left sidebar with tabs: General, Actions, Providers, History, Diagnostics. The window title SHALL be "InDraft Settings".

#### Scenario: Open settings
- **WHEN** the user clicks "Settings" in the menu bar dropdown
- **THEN** the settings window opens and comes to front with the previously selected tab (or General on first open)

## REMOVED Requirements

### Requirement: Retry Last action in dropdown
**Reason:** Feature adds UI clutter without sufficient value. Users can re-trigger actions via hotkey.
**Migration:** None needed — feature was never released.