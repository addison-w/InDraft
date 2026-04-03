## ADDED Requirements

### Requirement: Onboarding launches on first run
The onboarding flow SHALL launch automatically when the app detects no completed onboarding.

#### Scenario: First run triggers onboarding
- **WHEN** the app launches for the first time
- **THEN** the onboarding window opens at Step 1 (Welcome)

#### Scenario: Completed onboarding skips flow
- **WHEN** the app launches with previously completed onboarding
- **THEN** no onboarding window opens

### Requirement: Welcome step
Step 1 SHALL display the value proposition: "Rewrite anything, anywhere." with a description and "Get Started" button. Subtitle: "Takes about 2 minutes to set up."

#### Scenario: Welcome step display
- **WHEN** the onboarding opens
- **THEN** the welcome screen shows the tagline, description, and "Get Started" CTA

### Requirement: Accessibility permission step (required)
Step 2 SHALL explain why Accessibility permission is needed, provide a link/button to System Settings > Privacy & Security > Accessibility, and show real-time permission status. This step SHALL NOT be skippable.

#### Scenario: Permission not yet granted
- **WHEN** the user is on Step 2 without Accessibility permission
- **THEN** the "Continue" button is disabled AND instructions show how to grant permission

#### Scenario: Permission granted during step
- **WHEN** the user grants Accessibility permission in System Settings while Step 2 is visible
- **THEN** the permission status updates in real-time (without app restart) AND "Continue" becomes enabled

### Requirement: Add provider step (required)
Step 3 SHALL present a form for provider configuration: display name, base URL (pre-filled with `https://api.openai.com/v1`), API key (masked), and default model. This step SHALL NOT be skippable.

#### Scenario: Provider form with defaults
- **WHEN** the user reaches Step 3
- **THEN** the base URL field is pre-filled with `https://api.openai.com/v1`

#### Scenario: Provider saved
- **WHEN** the user fills in all fields and the form validates
- **THEN** the provider is saved to the database with API key in Keychain

### Requirement: Test connection step (required)
Step 4 SHALL test the configured provider. This step SHALL NOT be skippable — the test MUST pass to proceed.

#### Scenario: Test passes
- **WHEN** the connection test succeeds
- **THEN** a success indicator is shown AND "Continue" becomes enabled

#### Scenario: Test fails
- **WHEN** the connection test fails
- **THEN** a specific error message is shown AND "Continue" remains disabled AND the user can go back to fix provider settings

### Requirement: Default actions overview step (skippable)
Step 5 SHALL display the 3 default actions with their hotkeys. This step is skippable.

#### Scenario: Default actions shown
- **WHEN** the user reaches Step 5
- **THEN** all 3 default actions are listed with their names and hotkey combinations

### Requirement: Sample transformation step (skippable)
Step 6 SHALL provide a text area with sample text and a "Try It" button that runs Rewrite for Clarity. This step is skippable.

#### Scenario: Try sample transformation
- **WHEN** the user clicks "Try It" with sample text
- **THEN** the Rewrite for Clarity action runs on the sample text AND the result is displayed in the text area

### Requirement: Complete step
Step 7 SHALL confirm setup is complete with "You're all set." message, show the 3 default actions with hotkeys, and provide options to open settings or dismiss.

#### Scenario: Setup complete
- **WHEN** the user reaches Step 7
- **THEN** the configured provider is set as active AND the completion screen shows default action hotkeys

### Requirement: Onboarding resume on quit
If the user quits during onboarding, the app SHALL resume at the incomplete step on next launch.

#### Scenario: Quit during onboarding
- **WHEN** the user quits at Step 3 (provider setup)
- **THEN** the next launch opens onboarding at Step 3
