## ADDED Requirements

### Requirement: Onboarding window centers on primary display

The onboarding window SHALL center itself on the user's primary display when first shown. The window uses `NSScreen.main` to determine the target screen and calculates the center position accordingly.

#### Scenario: Window appears centered on launch
- **WHEN** the onboarding window is shown for the first time
- **THEN** the window SHALL be positioned at the center of the primary display

#### Scenario: Window reappears after close
- **WHEN** the onboarding window is shown again after being closed
- **THEN** the window SHALL center on the primary display again

### Requirement: Onboarding window size provides adequate space

The onboarding window SHALL be 580×540 points to accommodate all step content including illustrations, form fields, and the test connection button without overflow or scrolling.

#### Scenario: Provider step with test connection visible
- **WHEN** the user is on the AI provider step and all fields are filled
- **THEN** the test connection button and result status SHALL be fully visible within the window bounds without clipping or scrolling

#### Scenario: Steps with illustrations fit within window
- **WHEN** any onboarding step is displayed with its illustration
- **THEN** all content (illustration, title, description, interactive elements, navigation) SHALL fit within the 580×540 window without overflow

### Requirement: Back button navigates to welcome screen from step 1

The back button on step 1 (Accessibility) SHALL navigate back to the welcome screen (step 0). The activation policy MUST remain `.accessory` — no window management or activation policy changes.

#### Scenario: User presses back on Accessibility step
- **WHEN** the user is on step 1 (Accessibility) and presses the BACK button
- **THEN** the view SHALL transition back to the welcome screen (step 0) with a backward slide animation

#### Scenario: User presses back on step 2
- **WHEN** the user is on step 2 (AI Provider) and presses BACK
- **THEN** the view SHALL transition back to step 1 (Accessibility)

### Requirement: No skip button on optional steps

The onboarding flow SHALL NOT display a separate SKIP button. The CONTINUE button SHALL always be enabled on optional steps (steps 2–5). If the user has not provided input on an optional step, pressing CONTINUE SHALL advance to the next step without saving data.

#### Scenario: Continue without provider input
- **WHEN** the user is on step 2 (AI Provider) with empty fields and presses CONTINUE
- **THEN** the flow SHALL advance to step 3 without saving any provider configuration

#### Scenario: Continue with provider input
- **WHEN** the user is on step 2 with all fields filled and presses CONTINUE
- **THEN** the flow SHALL save the provider configuration and advance to step 3

#### Scenario: No skip button visible
- **WHEN** any onboarding step is displayed
- **THEN** no SKIP button SHALL be visible in the navigation area

### Requirement: Test connection button always visible on provider step

The test connection button on the AI provider step SHALL always be visible. It SHALL be disabled when required fields are incomplete, and enabled when all fields are filled.

#### Scenario: Fields incomplete
- **WHEN** the user is on the provider step and one or more fields are empty
- **THEN** the TEST CONNECTION button SHALL be visible but disabled with dimmed styling

#### Scenario: Fields complete
- **WHEN** the user is on the provider step and all fields are filled
- **THEN** the TEST CONNECTION button SHALL be enabled and interactive

### Requirement: Wabi-sabi illustrations on all onboarding steps

Each onboarding step (steps 1–4) SHALL display a wabi-sabi style illustration consistent with the welcome and completion screens. Illustrations SHALL be pure SwiftUI Path drawings — minimalist Japanese line art with sparse zen composition, asymmetry, clean negative space, and delicate hand-drawn aesthetic.

#### Scenario: Accessibility step displays shield illustration
- **WHEN** the accessibility step is displayed
- **THEN** a wabi-sabi shield/protection illustration SHALL be rendered above the title

#### Scenario: Provider step displays key illustration
- **WHEN** the AI provider step is displayed
- **THEN** a wabi-sabi key/connection illustration SHALL be rendered above the title

#### Scenario: Default actions step displays pen illustration
- **WHEN** the default actions step is displayed
- **THEN** a wabi-sabi pen/brush illustration SHALL be rendered above the title

#### Scenario: Sample transform step displays spark illustration
- **WHEN** the sample transform step is displayed
- **THEN** a wabi-sabi spark/transformation illustration SHALL be rendered above the title

### Requirement: Consistent centered layout across all steps

All onboarding steps (1–5) SHALL use a centered layout composition consistent with the welcome and completion screens. Content SHALL be centered horizontally with generous negative space. Content cards (instruction panels, form fields, action lists) SHALL remain left-aligned within the centered container.

#### Scenario: Step content is horizontally centered
- **WHEN** any onboarding step is displayed
- **THEN** the illustration, title, and description text SHALL be horizontally centered within the window

#### Scenario: Navigation bar consistent across steps
- **WHEN** any step from 1–5 is displayed
- **THEN** the BACK button SHALL appear at bottom-left and CONTINUE/FINISH at bottom-right with consistent spacing
