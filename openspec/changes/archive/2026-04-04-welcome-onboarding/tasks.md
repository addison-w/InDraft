## 1. Theme Extensions

- [x] 1.1 Add `Theme.Illustrations` namespace to Theme.swift with ink stroke color (textPrimary at 80% opacity), stroke width range (1.0–2.0pt), and illustration height constant (80pt)
- [x] 1.2 Add `Theme.OnboardingLayout` namespace to Theme.swift with content max-width (360pt) and step indicator dot size (6pt)

## 2. Ink-Line Art Components

- [x] 2.1 Create `WabiSabiArrowIllustration` SwiftUI Shape in Views/Onboarding/ — upward arrow motif with sparse asymmetric ink strokes, slight width variation for hand-drawn feel
- [x] 2.2 Create `WabiSabiCheckmarkIllustration` SwiftUI Shape in Views/Onboarding/ — simple checkmark motif for the complete step, using same ink stroke style

## 3. Onboarding Container Redesign

- [x] 3.1 Add `StepIndicatorView` component — horizontal dot pagination (6pt dots, xs gap, textPrimary filled for current, divider for others) with animated transitions
- [x] 3.2 Redesign `OnboardingContainerView` layout — integrate StepIndicatorView, set background to Theme.Colors.background, apply asymmetric slide+opacity transitions (Theme.Animation.gentle) for forward/backward navigation
- [x] 3.3 Standardize navigation bar across all steps — BACK (left, allCaps, textSecondary) / CONTINUE (right, allCaps, textPrimary), SKIP for skippable steps, centered "Get Started" for Welcome only

## 4. Welcome Step Redesign

- [x] 4.1 Redesign `WelcomeStepView` — integrate WabiSabiArrowIllustration, apply pageTitle for headline, body+textSecondary for description, caption for subtitle, PrimaryButtonStyle for CTA, centered layout with 360pt max-width and generous spacing (xl/xxl)

## 5. Accessibility Step Redesign

- [x] 5.1 Redesign `AccessibilityStepView` — pageTitle for step title, body for explanation, caption+textTertiary for System Settings breadcrumb, statusGreen/statusRed for permission indicator, allCaps step counter ("STEP 1 OF X")

## 6. Provider Steps Redesign

- [x] 6.1 Redesign `AddProviderStepView` — InputFieldStyle for all form fields, allCaps labels above each field, md spacing between field groups, SecondaryButtonStyle for "Test Connection", SHOW toggle for API key using label typography
- [x] 6.2 Redesign `TestConnectionStepView` — apply Theme tokens for status indicators, success/failure states using statusGreen/statusRed, consistent typography hierarchy

## 7. Action & Sample Steps Redesign

- [x] 7.1 Redesign `DefaultActionsStepView` — display actions with Theme.Typography.body for names, Theme.Keycap/KeycapRow for hotkey display, consistent card or list styling
- [x] 7.2 Redesign `SampleTransformStepView` — apply InputFieldStyle to text area, PrimaryButtonStyle for "Try It" button, consistent spacing and typography

## 8. Complete Step Redesign

- [x] 8.1 Redesign `CompleteStepView` — WabiSabiCheckmarkIllustration or statusGreen checkmark icon, pageTitle for "You're all set.", body for description, action rows with Keycap styling, allCaps step counter

## 9. Verification

- [x] 9.1 Build the project and verify zero compilation errors (passed — only pre-existing Sendable warnings)
- [x] 9.2 Grep all onboarding view files to confirm no hardcoded Color, Font, or numeric spacing values — all must reference Theme.*
- [ ] 9.3 Visual verification — run the app, reset onboarding, screenshot each step to confirm design reference match (requires manual testing)
