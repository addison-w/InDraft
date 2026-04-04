## MODIFIED Requirements

### Requirement: Settings window always activates to front
The settings window SHALL always come to front when opened from the menu bar dropdown, regardless of what other apps are focused. The window controller SHALL use `orderFrontRegardless()` combined with `NSApp.activate()` to ensure reliable activation without changing activation policy. The settings window SHALL use `NSWindow.Level.floating` to remain visible above normal application windows at all times, not just on initial activation.

#### Scenario: Open settings from dropdown while another app is focused
- **WHEN** the user clicks "Settings" in the menu bar dropdown AND another application is in the foreground
- **THEN** the settings window appears in front of all other windows AND receives keyboard focus

#### Scenario: Settings window already open but behind other windows
- **WHEN** the user clicks "Settings" in the dropdown AND the settings window is already open but not visible
- **THEN** the existing settings window is brought to front and receives keyboard focus

#### Scenario: Settings window stays visible after user switches apps
- **WHEN** the settings window is open AND the user clicks on another application
- **THEN** the settings window remains visible above the other application's windows due to floating window level

### Requirement: History window always activates to front
The history window SHALL always come to front when opened from the menu bar dropdown, regardless of what other apps are focused. The window controller SHALL use `orderFrontRegardless()` combined with `NSApp.activate()` to ensure reliable activation without changing activation policy. The history window SHALL use `NSWindow.Level.floating` to remain visible above normal application windows at all times, not just on initial activation.

#### Scenario: Open history from dropdown while another app is focused
- **WHEN** the user clicks "History" in the menu bar dropdown AND another application is in the foreground
- **THEN** the history window appears in front of all other windows AND receives keyboard focus

#### Scenario: History window already open but behind other windows
- **WHEN** the user clicks "History" in the dropdown AND the history window is already open but not visible
- **THEN** the existing history window is brought to front and receives keyboard focus

#### Scenario: History window stays visible after user switches apps
- **WHEN** the history window is open AND the user clicks on another application
- **THEN** the history window remains visible above the other application's windows due to floating window level
