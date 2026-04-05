## ADDED Requirements

### Requirement: Translate to English predefined action
The system SHALL include a "Translate to English" predefined action with the prompt "Translate the text to English. Preserve the original meaning, tone, and formatting. If the text is already in English, return it unchanged." assigned to the hotkey Ctrl+Opt+4.

#### Scenario: Fresh install includes Translate to English action
- **WHEN** the app is launched for the first time and seed data is created
- **THEN** an action named "Translate to English" SHALL exist with sortOrder 3, hotkey Ctrl+Opt+4, and outputBehavior .replace

#### Scenario: Translate to English action appears in menu bar
- **WHEN** the user opens the menu bar dropdown
- **THEN** the "Translate to English" action SHALL appear with the translate icon

### Requirement: Professional Tone predefined action
The system SHALL include a "Professional Tone" predefined action with the prompt "Rewrite the text in a professional, polished tone suitable for business communication. Maintain the original meaning and key points while elevating the language." assigned to the hotkey Ctrl+Opt+5.

#### Scenario: Fresh install includes Professional Tone action
- **WHEN** the app is launched for the first time and seed data is created
- **THEN** an action named "Professional Tone" SHALL exist with sortOrder 4, hotkey Ctrl+Opt+5, and outputBehavior .replace

#### Scenario: Professional Tone action appears in menu bar
- **WHEN** the user opens the menu bar dropdown
- **THEN** the "Professional Tone" action SHALL appear with the professional/briefcase icon

### Requirement: ELI5 predefined action
The system SHALL include an "ELI5" predefined action with the prompt "Explain this like I'm five. Use simple words, short sentences, and relatable analogies. Make it easy to understand for anyone, regardless of background." assigned to the hotkey Ctrl+Opt+6.

#### Scenario: Fresh install includes ELI5 action
- **WHEN** the app is launched for the first time and seed data is created
- **THEN** an action named "ELI5" SHALL exist with sortOrder 5, hotkey Ctrl+Opt+6, and outputBehavior .replace

#### Scenario: ELI5 action appears in menu bar
- **WHEN** the user opens the menu bar dropdown
- **THEN** the "ELI5" action SHALL appear with the simplify/baby icon

### Requirement: Seed data creates six default actions
The system SHALL create exactly 6 default actions on fresh install in this order: Grammar Fix, Rewrite for Clarity, Shorten, Translate to English, Professional Tone, ELI5.

#### Scenario: Fresh install creates all six actions
- **WHEN** the app is launched for the first time with no existing actions
- **THEN** `SeedData.createDefaultActions` SHALL insert 6 actions with sortOrder 0-5

#### Scenario: Existing users are not affected
- **WHEN** the app launches and actions already exist in the database
- **THEN** `SeedData.createDefaultActions` SHALL not modify any existing actions

### Requirement: Restore defaults includes all six actions
The system SHALL restore all 6 predefined actions when the user triggers "Restore Defaults" in settings.

#### Scenario: Restore defaults adds missing new actions
- **WHEN** a user who installed before this update triggers "Restore Defaults"
- **THEN** all 6 default actions SHALL exist with their default prompts and hotkeys
- **AND** any custom actions the user created SHALL be preserved
