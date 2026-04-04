## MODIFIED Requirements

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

### Requirement: Default hotkey assignments
The 3 default actions SHALL ship with pre-assigned hotkeys using NSEvent modifier flag encoding: Rewrite for Clarity (Control+Option+1), Grammar Fix (Control+Option+2), Paraphrase (Control+Option+3).

#### Scenario: Default hotkeys work after first setup
- **WHEN** the user completes onboarding
- **THEN** pressing Control+Option+1 triggers "Rewrite for Clarity" AND Control+Option+2 triggers "Grammar Fix" AND Control+Option+3 triggers "Paraphrase"

#### Scenario: Default action modifier encoding matches register() expectations
- **WHEN** default actions are created from `Constants.DefaultActions`
- **THEN** the `modifiers` value SHALL be encoded as `NSEvent.ModifierFlags` raw values (not Carbon modifier flags) so that `nsToCarbonModifiers()` converts them correctly
