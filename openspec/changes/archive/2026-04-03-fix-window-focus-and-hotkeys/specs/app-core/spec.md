## MODIFIED Requirements

### Requirement: App runs as menu bar background process
The app SHALL run as an LSUIElement (no dock icon) with a persistent menu bar icon. The app SHALL have no main window — all interaction happens via menu bar dropdown, settings window, history window, and floating preview panel. The app SHALL never change its activation policy — it MUST remain `.accessory` at all times.

#### Scenario: App launches as background process
- **WHEN** the user launches InDraft
- **THEN** a menu bar icon appears in the system menu bar AND no dock icon is shown AND no main window opens

#### Scenario: First launch triggers onboarding
- **WHEN** the user launches InDraft for the first time (no completed onboarding)
- **THEN** the onboarding window opens automatically

#### Scenario: Subsequent launch with completed setup
- **WHEN** the user launches InDraft with completed onboarding and valid provider
- **THEN** the app enters idle state with menu bar icon showing ready status

#### Scenario: App never shows dock icon
- **WHEN** any window is opened or closed
- **THEN** the app activation policy remains `.accessory` AND no dock icon appears

### Requirement: History window accessible from dropdown
The history window SHALL be accessible from the menu bar dropdown. Clicking "History" in the dropdown SHALL open the history window and bring it to front reliably, without changing activation policy.

#### Scenario: Open history from dropdown
- **WHEN** the user clicks "History" in the menu bar dropdown
- **THEN** the history window opens and comes to front using `orderFrontRegardless()` AND `NSApp.activate()` is called

#### Scenario: History window already open
- **WHEN** the user clicks "History" in the dropdown AND the history window is already open
- **THEN** the existing history window is brought to front using `orderFrontRegardless()` AND made key

## ADDED Requirements

### Requirement: Settings window always activates to front
The settings window SHALL always come to front when opened from the menu bar dropdown, regardless of what other apps are focused. The window controller SHALL use `orderFrontRegardless()` combined with `NSApp.activate()` to ensure reliable activation without changing activation policy.

#### Scenario: Open settings from dropdown while another app is focused
- **WHEN** the user clicks "Settings" in the menu bar dropdown AND another application is in the foreground
- **THEN** the settings window appears in front of all other windows AND receives keyboard focus

#### Scenario: Settings window already open but behind other windows
- **WHEN** the user clicks "Settings" in the dropdown AND the settings window is already open but not visible
- **THEN** the existing settings window is brought to front and receives keyboard focus

### Requirement: History window always activates to front
The history window SHALL always come to front when opened from the menu bar dropdown, regardless of what other apps are focused. The window controller SHALL use `orderFrontRegardless()` combined with `NSApp.activate()` to ensure reliable activation without changing activation policy.

#### Scenario: Open history from dropdown while another app is focused
- **WHEN** the user clicks "History" in the menu bar dropdown AND another application is in the foreground
- **THEN** the history window appears in front of all other windows AND receives keyboard focus

#### Scenario: History window already open but behind other windows
- **WHEN** the user clicks "History" in the dropdown AND the history window is already open but not visible
- **THEN** the existing history window is brought to front and receives keyboard focus

## REMOVED Requirements

### Requirement: Dock icon is toggleable
**Reason**: The app should never show a dock icon. The toggleable dock icon preference added complexity to window controllers and caused unreliable window activation. The app is a pure menu bar utility.
**Migration**: The `showDockIcon` UserDefaults key is no longer read. The General Settings toggle is removed. No user action needed — the app simply never shows a dock icon.
