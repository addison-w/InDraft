## ADDED Requirements

### Requirement: App windows use floating window level
All InDraft windows (Onboarding, Settings, History) SHALL use `NSWindow.Level.floating` so they remain visible above normal application windows. The activation policy SHALL remain `.accessory` at all times -- floating window level is used instead of activation policy changes to ensure window visibility.

#### Scenario: Settings window remains visible when switching apps
- **WHEN** the Settings window is open AND the user activates another application (e.g., clicks on Safari)
- **THEN** the Settings window remains visible above the other application's windows

#### Scenario: History window remains visible when switching apps
- **WHEN** the History window is open AND the user activates another application
- **THEN** the History window remains visible above the other application's windows

#### Scenario: Onboarding window remains visible when switching apps
- **WHEN** the Onboarding window is open AND the user activates another application
- **THEN** the Onboarding window remains visible above the other application's windows

#### Scenario: Floating windows do not block system modal dialogs
- **WHEN** an InDraft floating window is visible AND the system displays a modal dialog (e.g., permission prompt)
- **THEN** the system modal dialog appears above the InDraft window

### Requirement: Window level is set at creation time
Each window controller SHALL set the window level to `.floating` immediately after window creation, before the window is first displayed. The window level SHALL not change during the window's lifetime.

#### Scenario: Window is floating from first appearance
- **WHEN** the user opens Settings from the menu bar dropdown
- **THEN** the Settings window appears at the floating level from the first frame of display

#### Scenario: Window level persists across show/hide cycles
- **WHEN** the user closes and reopens the Settings window
- **THEN** the window is still at floating level when it reappears

### Requirement: Activation policy remains accessory
Setting window level to `.floating` SHALL NOT cause any change to the app's activation policy. The app SHALL remain an LSUIElement with `.accessory` activation policy. No dock icon SHALL appear as a result of this change.

#### Scenario: No dock icon after opening floating window
- **WHEN** the user opens any InDraft window (Settings, History, or Onboarding)
- **THEN** no dock icon appears for InDraft AND the activation policy remains `.accessory`
