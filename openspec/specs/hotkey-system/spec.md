## ADDED Requirements

### Requirement: System-wide global hotkey registration
Each action's hotkey SHALL be registered as a system-wide global hotkey that works while any application is focused. The service SHALL support an unlimited number of simultaneous hotkey registrations.

#### Scenario: Hotkey triggers action from any app
- **WHEN** the user presses an action's registered hotkey while any app is focused
- **THEN** the corresponding action's transformation is triggered

#### Scenario: Disabled action hotkey does not respond
- **WHEN** the user presses a hotkey assigned to a disabled action
- **THEN** no transformation is triggered AND the hotkey press is not consumed

#### Scenario: Register more than 2 hotkeys simultaneously
- **WHEN** the app has 3 or more enabled actions with distinct hotkey assignments
- **THEN** all hotkeys SHALL be registered successfully AND each hotkey triggers its corresponding action

#### Scenario: Re-registration after deregisterAll preserves clean state
- **WHEN** `deregisterAll()` is called AND new hotkeys are subsequently registered
- **THEN** internal Carbon Event IDs SHALL restart from 1 AND all new registrations succeed

#### Scenario: Multiple deregister-register cycles work reliably
- **WHEN** `deregisterAll()` followed by `register()` is called N times in sequence
- **THEN** every cycle SHALL successfully register all hotkeys without exhausting Carbon Event IDs

### Requirement: Independent hotkey configuration per action
Each action SHALL have an independently configurable hotkey via a key recorder UI component.

#### Scenario: Record a new hotkey
- **WHEN** the user clicks "Record" in the hotkey recorder AND presses a key combination
- **THEN** the key combination is displayed in the recorder AND registered as the action's hotkey

#### Scenario: Clear a hotkey
- **WHEN** the user clicks "Clear" in the hotkey recorder
- **THEN** the hotkey is removed from the action AND the system registration is released AND the action can still be triggered from the menu bar dropdown

### Requirement: Hotkey conflict detection
The app SHALL detect when a hotkey is already assigned to another action within InDraft and warn the user.

#### Scenario: Duplicate hotkey within app
- **WHEN** the user records a hotkey that is already assigned to another InDraft action
- **THEN** a warning is shown identifying the conflict AND the user must confirm or choose a different hotkey

#### Scenario: System-level registration failure
- **WHEN** hotkey registration fails (e.g., conflict with another application)
- **THEN** the app shows "Could not register [hotkey] — it may be in use by another application"

### Requirement: Hotkey changes take effect immediately
Hotkey registration and deregistration SHALL take effect immediately without requiring an app restart.

#### Scenario: Change hotkey in settings
- **WHEN** the user changes an action's hotkey in the action editor AND saves
- **THEN** the old hotkey is deregistered AND the new hotkey is registered AND works immediately

### Requirement: Default hotkey assignments
The 3 default actions SHALL ship with pre-assigned hotkeys using NSEvent modifier flag encoding: Rewrite for Clarity (Control+Option+1), Grammar Fix (Control+Option+2), Paraphrase (Control+Option+3).

#### Scenario: Default hotkeys work after first setup
- **WHEN** the user completes onboarding
- **THEN** pressing Control+Option+1 triggers "Rewrite for Clarity" AND Control+Option+2 triggers "Grammar Fix" AND Control+Option+3 triggers "Paraphrase"

#### Scenario: Default action modifier encoding matches register() expectations
- **WHEN** default actions are created from `Constants.DefaultActions`
- **THEN** the `modifiers` value SHALL be encoded as `NSEvent.ModifierFlags` raw values (not Carbon modifier flags) so that `nsToCarbonModifiers()` converts them correctly
