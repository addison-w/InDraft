## ADDED Requirements

### Requirement: Onboarding launches on first run
The onboarding flow SHALL launch automatically when the app detects no completed onboarding.

#### Scenario: First run triggers onboarding
- **WHEN** the app launches for the first time
- **THEN** the onboarding window opens at Step 1 (Welcome)

#### Scenario: Completed onboarding skips flow
- **WHEN** the app launches with previously completed onboarding
- **THEN** no onboarding window opens

### Requirement: Onboarding step count
The onboarding flow SHALL have exactly 6 steps (indexed 0 through 5): Welcome, Accessibility Permission, Add Provider, Default Actions, Sample Transform, and Complete.

#### Scenario: Total step count
- **WHEN** the onboarding flow is displayed
- **THEN** the step indicator SHALL show "STEP X OF 5" for steps that display an indicator

#### Scenario: Skippable steps
- **WHEN** the user is on a skippable step (Add Provider, Default Actions, Sample Transform)
- **THEN** a Skip button SHALL be visible in the navigation bar

### Requirement: Welcome step
Step 1 SHALL display the value proposition: "Rewrite anything, anywhere." with a description and "Get Started" button. Subtitle: "Takes about 2 minutes to set up." The welcome step SHALL feature a wabi-sabi ink-line illustration (upward arrow motif) above the headline, drawn as a SwiftUI Shape using theme colors. All visual properties SHALL use Theme.swift tokens exclusively.

#### Scenario: Welcome step display
- **WHEN** the onboarding opens
- **THEN** the welcome screen shows an ink-line illustration, the tagline in pageTitle typography, description in body typography, and "Get Started" CTA using PrimaryButtonStyle

#### Scenario: Welcome step visual consistency
- **WHEN** the welcome screen renders
- **THEN** all colors, fonts, and spacing reference Theme.swift tokens with no hardcoded values

### Requirement: Accessibility permission step (required)
Step 2 SHALL explain why Accessibility permission is needed, provide a link/button to System Settings > Privacy & Security > Accessibility, and show real-time permission status. This step SHALL NOT be skippable. The step title SHALL use Theme.Typography.pageTitle. The navigation breadcrumb SHALL use Theme.Typography.caption in textTertiary color. The permission status SHALL display using statusGreen (granted) or statusRed (not granted) from Theme.Colors.

#### Scenario: Permission not yet granted
- **WHEN** the user is on the Accessibility step without Accessibility permission
- **THEN** the "Continue" button is disabled AND instructions show how to grant permission AND status shows "NOT GRANTED" in statusRed color

#### Scenario: Permission granted during step
- **WHEN** the user grants Accessibility permission in System Settings while the Accessibility step is visible
- **THEN** the permission status updates in real-time (without app restart) to show statusGreen AND "Continue" becomes enabled

### Requirement: Add provider step (skippable)
Step 3 SHALL present a form for provider configuration: display name, base URL (placeholder showing `https://api.openai.com/v1`), API key (masked), and default model. This step SHALL be skippable — the user MAY skip without filling in any fields. All form fields SHALL use Theme.InputFieldStyle. Field labels SHALL use Theme.Typography.allCaps positioned above each field.

#### Scenario: Provider form with defaults
- **WHEN** the user reaches the Add Provider step
- **THEN** the base URL field SHALL show a placeholder of `https://api.openai.com/v1`

#### Scenario: Provider saved when fields are filled
- **WHEN** the user fills in all required fields (display name, base URL, API key, model) and taps Continue
- **THEN** the provider SHALL be saved to the database with the API key stored in Keychain

#### Scenario: Provider not saved on skip
- **WHEN** the user taps Skip on the Add Provider step without filling in all fields
- **THEN** no provider SHALL be saved
- **AND** the user SHALL advance to the Default Actions step

#### Scenario: Inline test connection button appears
- **WHEN** all required provider fields (display name, base URL, API key, model) are filled
- **THEN** a "Test Connection" button SHALL appear below the form fields

#### Scenario: Inline test connection succeeds
- **WHEN** the user taps "Test Connection" and the API call succeeds
- **THEN** a success indicator SHALL be displayed inline below the form

#### Scenario: Inline test connection fails
- **WHEN** the user taps "Test Connection" and the API call fails
- **THEN** a failure indicator with a specific error message SHALL be displayed inline below the form
- **AND** the user SHALL be able to edit fields and retry

#### Scenario: Continue without testing
- **WHEN** all required provider fields are filled but the user has not tested the connection
- **THEN** the "Continue" button SHALL still be enabled
- **AND** the provider SHALL be saved when Continue is tapped

### Requirement: Default actions overview step (skippable)
Step 4 SHALL display all 6 predefined actions (Grammar Fix, Rewrite for Clarity, Shorten, Translate to English, Professional Tone, ELI5) with their assigned hotkeys during onboarding. This step is skippable.

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

### Requirement: Sample transformation step (skippable)
Step 5 SHALL provide a text area with sample text and a "Try It" button that runs Rewrite for Clarity. This step is skippable.

#### Scenario: Try sample transformation
- **WHEN** the user clicks "Try It" with sample text
- **THEN** the Rewrite for Clarity action SHALL run on the sample text
- **AND** the result SHALL be displayed in the text area

### Requirement: Complete step
Step 6 SHALL confirm setup is complete with "You're all set." message using Theme.Typography.pageTitle, show a wabi-sabi checkmark illustration, display the 6 default actions with hotkeys using Theme.Keycap styling, and show "STEP X OF X" using Theme.Typography.allCaps.

#### Scenario: Setup complete with provider
- **WHEN** the user reaches the Complete step after configuring a provider
- **THEN** the configured provider SHALL be set as active
- **AND** the completion screen SHALL show default action hotkeys using Keycap styling

#### Scenario: Setup complete without provider
- **WHEN** the user reaches the Complete step after skipping the provider step
- **THEN** no provider SHALL be set as active
- **AND** the completion screen SHALL indicate that a provider can be added in Settings

### Requirement: Onboarding resume on quit
If the user quits during onboarding, the app SHALL resume at the incomplete step on next launch.

#### Scenario: Quit during onboarding
- **WHEN** the user quits at a mid-onboarding step
- **THEN** the next launch opens onboarding at that step

### Requirement: Onboarding Container Dimensions
The onboarding window SHALL have dimensions that provide comfortable visual breathing room.

#### Scenario: Onboarding window frame
- **WHEN** the onboarding window is displayed
- **THEN** the frame SHALL be 540x480 points

### Requirement: Step Indicator Spacing
The step indicator ("STEP X OF Y") SHALL have adequate separation from content.

#### Scenario: Step indicator top margin
- **WHEN** the step indicator is displayed
- **THEN** it SHALL have `.padding(.top, Theme.Spacing.xl)` top spacing
