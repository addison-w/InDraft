# Spec: Onboarding Flow (Delta)

## MODIFIED Requirements

### Requirement: Add provider step (required)
Step 3 SHALL present a form for provider configuration: display name, base URL (placeholder showing `https://api.openai.com/v1`), API key (masked), and default model. This step SHALL be **skippable** --- the user MAY skip without filling in any fields.

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
- **AND** the "Continue" button SHALL be enabled

#### Scenario: Inline test connection fails
- **WHEN** the user taps "Test Connection" and the API call fails
- **THEN** a failure indicator with a specific error message SHALL be displayed inline below the form
- **AND** the user SHALL be able to edit fields and retry

#### Scenario: Continue without testing
- **WHEN** all required provider fields are filled but the user has not tested the connection
- **THEN** the "Continue" button SHALL still be enabled
- **AND** the provider SHALL be saved when Continue is tapped

### Requirement: Test connection step (required)
**This requirement is removed.** The standalone test connection step no longer exists. Test connection functionality is now inline within the Add Provider step.

### Requirement: Default actions overview step (skippable)
Step 4 SHALL display the 3 default actions with their hotkeys. This step is skippable.

#### Scenario: Default actions shown
- **WHEN** the user reaches the Default Actions step
- **THEN** all 3 default actions SHALL be listed with their names and hotkey combinations

### Requirement: Sample transformation step (skippable)
Step 5 SHALL provide a text area with sample text and a "Try It" button that runs Rewrite for Clarity. This step is skippable.

#### Scenario: Try sample transformation
- **WHEN** the user clicks "Try It" with sample text
- **THEN** the Rewrite for Clarity action SHALL run on the sample text
- **AND** the result SHALL be displayed in the text area

### Requirement: Complete step
Step 6 SHALL confirm setup is complete with "You're all set." message, show the 3 default actions with hotkeys, and provide options to open settings or dismiss.

#### Scenario: Setup complete with provider
- **WHEN** the user reaches the Complete step after configuring a provider
- **THEN** the configured provider SHALL be set as active
- **AND** the completion screen SHALL show default action hotkeys

#### Scenario: Setup complete without provider
- **WHEN** the user reaches the Complete step after skipping the provider step
- **THEN** no provider SHALL be set as active
- **AND** the completion screen SHALL indicate that a provider can be added in Settings

### Requirement: Onboarding step count
The onboarding flow SHALL have exactly 6 steps (indexed 0 through 5): Welcome, Accessibility Permission, Add Provider, Default Actions, Sample Transform, and Complete.

#### Scenario: Total step count
- **WHEN** the onboarding flow is displayed
- **THEN** the step indicator SHALL show "STEP X OF 6" for steps that display an indicator

#### Scenario: Skippable steps
- **WHEN** the user is on a skippable step (Add Provider, Default Actions, Sample Transform)
- **THEN** a Skip button SHALL be visible in the navigation bar

## REMOVED Requirements

### Requirement: Test connection step (required)
**Reason**: The standalone test connection step added unnecessary friction. Test connection is now an inline action within the Add Provider step.
**Migration**: Test connection UI and logic are merged into AddProviderStepView. TestConnectionStepView is removed from step routing.
