## ADDED Requirements

### Requirement: Onboarding views use Theme tokens exclusively
All onboarding view files SHALL reference Theme.Colors, Theme.Typography, Theme.Spacing, and Theme.CornerRadius for every visual property. No hardcoded Color, Font, or numeric spacing/size values SHALL appear in onboarding views.

#### Scenario: Theme compliance across all onboarding views
- **WHEN** any onboarding view file is inspected
- **THEN** every color reference uses Theme.Colors.*, every font uses Theme.Typography.*, every spacing uses Theme.Spacing.*, and every corner radius uses Theme.CornerRadius.*

### Requirement: Welcome screen wabi-sabi ink-line illustration
The WelcomeStepView SHALL display a wabi-sabi ink-line illustration above the headline. The illustration SHALL be drawn as a SwiftUI Path/Shape using Theme.Colors.textPrimary at 80% opacity with stroke widths between 1.0–2.0pt. The composition SHALL be sparse and asymmetric, evoking hand-drawn imperfection.

#### Scenario: Welcome illustration renders
- **WHEN** the welcome step is displayed
- **THEN** an ink-line illustration (upward arrow motif) renders above the headline at approximately 80pt height

#### Scenario: Illustration uses theme colors
- **WHEN** the welcome illustration is rendered
- **THEN** all strokes use Theme.Colors.textPrimary at 80% opacity with no hardcoded color values

### Requirement: Welcome screen typography hierarchy
The WelcomeStepView SHALL display the headline "Rewrite anything, anywhere." using Theme.Typography.pageTitle, a body description using Theme.Typography.body with Theme.Colors.textSecondary, and the subtitle "Takes about 2 minutes to set up." using Theme.Typography.caption.

#### Scenario: Welcome typography matches design
- **WHEN** the welcome step is displayed
- **THEN** the headline uses pageTitle style, the description uses body style in textSecondary, and the subtitle uses caption style

### Requirement: Welcome screen centered sparse layout
The WelcomeStepView content SHALL be vertically and horizontally centered within the onboarding window with a maximum content width of 360pt. Vertical spacing between illustration, headline, description, and CTA button SHALL use Theme.Spacing.xl (24pt) or Theme.Spacing.xxl (32pt).

#### Scenario: Welcome layout composition
- **WHEN** the welcome step is displayed
- **THEN** all content is centered with generous negative space and content does not exceed 360pt width

### Requirement: Step indicator dot pagination
The OnboardingContainerView SHALL display a horizontal row of dot indicators representing each step. The current step dot SHALL be filled with Theme.Colors.textPrimary. Inactive step dots SHALL use Theme.Colors.divider. Each dot SHALL be 6pt diameter with Theme.Spacing.xs (4pt) horizontal gaps.

#### Scenario: Step indicator shows current position
- **WHEN** the user is on step 3 of the onboarding
- **THEN** the third dot is filled with textPrimary and all other dots use divider color

#### Scenario: Step indicator updates on navigation
- **WHEN** the user advances from step 2 to step 3
- **THEN** the third dot fills and the second dot unfills with an animated transition

### Requirement: Step transition animations
Navigation between onboarding steps SHALL use asymmetric SwiftUI transitions: forward navigation slides content from trailing to leading with opacity fade; backward navigation reverses direction. The animation duration SHALL be Theme.Animation.gentle (300ms).

#### Scenario: Forward step transition
- **WHEN** the user taps "Continue" to advance to the next step
- **THEN** the current step content slides out to the leading edge while the next step slides in from the trailing edge, both with opacity fade, over 300ms

#### Scenario: Backward step transition
- **WHEN** the user taps "Back" to return to the previous step
- **THEN** the current step content slides out to the trailing edge while the previous step slides in from the leading edge, over 300ms

### Requirement: Navigation bar consistency
All onboarding steps (except Welcome) SHALL display a consistent bottom navigation bar with "BACK" on the leading edge (Theme.Typography.allCaps, Theme.Colors.textSecondary) and "CONTINUE" on the trailing edge (Theme.Typography.allCaps, Theme.Colors.textPrimary). Skippable steps SHALL show "SKIP" adjacent to "CONTINUE". The Welcome step SHALL show only a centered "Get Started" button using Theme.PrimaryButtonStyle.

#### Scenario: Navigation bar on required step
- **WHEN** the user is on the Accessibility step (required, not first)
- **THEN** "BACK" appears on the left and "CONTINUE" on the right with no "SKIP" option

#### Scenario: Navigation bar on skippable step
- **WHEN** the user is on the Default Actions step (skippable)
- **THEN** "BACK" appears on the left and both "SKIP" and "CONTINUE" appear on the right

#### Scenario: Welcome step CTA
- **WHEN** the welcome step is displayed
- **THEN** only a centered "Get Started" button is shown, no BACK/CONTINUE bar

### Requirement: Accessibility step visual design
The AccessibilityStepView SHALL display the step title using Theme.Typography.pageTitle, an explanation using Theme.Typography.body, a navigation breadcrumb ("System Settings > Privacy & Security > Accessibility") styled as Theme.Typography.caption with Theme.Colors.textTertiary, and a real-time permission status indicator using Theme.Colors.statusGreen (granted) or Theme.Colors.statusRed (not granted).

#### Scenario: Permission not granted visual state
- **WHEN** the Accessibility step shows permission not granted
- **THEN** the status indicator displays "NOT GRANTED" in Theme.Colors.statusRed with instructions visible

#### Scenario: Permission granted visual state
- **WHEN** Accessibility permission is granted
- **THEN** the status indicator updates to show a green checkmark or "GRANTED" in Theme.Colors.statusGreen

### Requirement: Provider form visual design
The AddProviderStepView form SHALL use Theme.InputFieldStyle for all text fields, Theme.Typography.allCaps for field labels positioned above each field, and Theme.Spacing.md (12pt) vertical gaps between field groups. The "Test Connection" button SHALL use Theme.SecondaryButtonStyle positioned below the form with Theme.Spacing.xl separation.

#### Scenario: Provider form field styling
- **WHEN** the Add Provider step is displayed
- **THEN** all form fields use InputFieldStyle, labels use allCaps typography, and spacing follows Theme tokens

#### Scenario: API key field is masked
- **WHEN** the API key field contains a value
- **THEN** the field displays masked characters with a "SHOW" toggle using Theme.Typography.label

### Requirement: Complete screen visual design
The CompleteStepView SHALL display a checkmark icon using Theme.Colors.statusGreen, the headline "You're all set." using Theme.Typography.pageTitle, a body description using Theme.Typography.body, and a list of default actions with their hotkeys displayed using Theme.Keycap styling. The step indicator SHALL show "STEP X OF X" using Theme.Typography.allCaps above the headline.

#### Scenario: Complete screen layout
- **WHEN** the complete step is displayed
- **THEN** a green checkmark icon, the "You're all set." headline, description, and action list with keycaps are displayed in centered layout

#### Scenario: Action list with hotkeys
- **WHEN** the complete step shows default actions
- **THEN** each action row displays the action name using Theme.Typography.body and the hotkey using Theme.Keycap/KeycapRow styling

### Requirement: Onboarding window background
The onboarding window background SHALL use Theme.Colors.background (warm bone #FAF9F6). The content card (if used) SHALL use Theme.Colors.cardBackground with Theme.CardStyle modifier.

#### Scenario: Window and card backgrounds
- **WHEN** any onboarding step is displayed
- **THEN** the window background is warm bone and any content cards use cardBackground with CardStyle
