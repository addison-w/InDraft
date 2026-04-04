## MODIFIED Requirements

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
- **WHEN** the user is on Step 2 without Accessibility permission
- **THEN** the "Continue" button is disabled AND instructions show how to grant permission AND status shows "NOT GRANTED" in statusRed color

#### Scenario: Permission granted during step
- **WHEN** the user grants Accessibility permission in System Settings while Step 2 is visible
- **THEN** the permission status updates in real-time (without app restart) to show statusGreen AND "Continue" becomes enabled

### Requirement: Add provider step (required)
Step 3 SHALL present a form for provider configuration: display name, base URL (placeholder showing `https://api.openai.com/v1`), API key (masked), and default model. This step SHALL NOT be skippable. All form fields SHALL use Theme.InputFieldStyle. Field labels SHALL use Theme.Typography.allCaps positioned above each field. The "Test Connection" button SHALL use Theme.SecondaryButtonStyle.

#### Scenario: Provider form with defaults
- **WHEN** the user reaches Step 3
- **THEN** the base URL field shows a placeholder with `https://api.openai.com/v1` AND all fields use InputFieldStyle AND labels use allCaps typography

#### Scenario: Provider saved
- **WHEN** the user fills in all fields and the form validates
- **THEN** the provider is saved to the database with API key in Keychain

### Requirement: Complete step
Step 7 SHALL confirm setup is complete with "You're all set." message using Theme.Typography.pageTitle, show a checkmark icon in Theme.Colors.statusGreen, display the 3 default actions with hotkeys using Theme.Keycap styling, and show "STEP X OF X" using Theme.Typography.allCaps. The layout SHALL provide options to open settings or dismiss.

#### Scenario: Setup complete
- **WHEN** the user reaches Step 7
- **THEN** the configured provider is set as active AND the completion screen shows a green checkmark, the headline, and default action hotkeys using Keycap styling
