## MODIFIED Requirements

### Requirement: Default actions onboarding step displays all predefined actions
The DefaultActionsStepView SHALL display all 6 predefined actions (Grammar Fix, Rewrite for Clarity, Shorten, Translate to English, Professional Tone, ELI5) with their assigned hotkeys during onboarding.

#### Scenario: Onboarding shows six actions
- **WHEN** the user reaches the Default Actions step during onboarding
- **THEN** the view SHALL display 6 action rows showing each action name in uppercase with its corresponding keycap hotkey

#### Scenario: Onboarding subtitle reflects six actions
- **WHEN** the Default Actions step is displayed
- **THEN** the subtitle text SHALL reference six built-in actions (not three)

#### Scenario: All six actions fit within the onboarding card
- **WHEN** the Default Actions step is displayed
- **THEN** all 6 action rows SHALL be visible within the card without scrolling
- **AND** the layout SHALL use compact vertical padding to accommodate the additional rows
