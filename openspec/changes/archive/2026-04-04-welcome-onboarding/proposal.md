## Why

The current onboarding views use basic SwiftUI defaults and lack the refined editorial aesthetic established in the rest of the app (Theme.swift). First impressions define user perception — the welcome screen and onboarding steps need to embody the "Technical Curator" design language with a Japanese wabi-sabi sensibility: sparse composition, deliberate asymmetry, ink-line illustrations, and generous negative space. The design reference screenshots (designs/02–06) define the target visual standard.

## What Changes

- **Redesign WelcomeStepView** with wabi-sabi ink-line illustration (upward arrow/pen motif), refined typography hierarchy, and centered sparse composition matching the design reference
- **Redesign AccessibilityStepView** with clearer visual hierarchy, status indicator (granted/not granted), and navigation path breadcrumb styled as quiet editorial detail
- **Redesign AddProviderStepView** with refined form fields using Theme.InputFieldStyle, proper label typography, and "Test Connection" button following Theme.PrimaryButtonStyle
- **Redesign CompleteStepView** with checkmark icon, celebration typography, and action summary cards showing hotkey keycaps
- **Redesign OnboardingContainerView** layout with consistent step indicator (dot pagination), BACK/CONTINUE navigation bar, and smooth step transitions
- **Add wabi-sabi ink-line art assets** — minimal decorative illustrations for welcome and completion screens using simple black ink strokes on warm bone background
- **Ensure all onboarding views use Theme tokens** exclusively — no hardcoded colors, fonts, or spacing values

## Non-goals

- Changing onboarding flow logic or step order (functional behavior stays identical)
- Adding or removing onboarding steps
- Modifying Provider/Action data models or service layer
- Changing window management, activation policy, or app lifecycle
- Adding new UserDefaults keys or persistence changes

## Capabilities

### New Capabilities

- `onboarding-visual-design`: Visual design system for onboarding screens — wabi-sabi ink-line art style, typography composition, layout patterns, step indicator design, and transition animations specific to the onboarding flow

### Modified Capabilities

- `onboarding-flow`: Visual presentation requirements are changing — adding specific layout, typography, illustration, and animation requirements to existing functional specs. Step structure and logic remain unchanged.

## Impact

- **Views modified**: `WelcomeStepView`, `AccessibilityStepView`, `AddProviderStepView`, `TestConnectionStepView`, `DefaultActionsStepView`, `SampleTransformStepView`, `CompleteStepView`, `OnboardingContainerView`
- **Utilities**: `Theme.swift` may need additional tokens for onboarding-specific illustration colors or animation curves
- **Assets**: New ink-line art assets (SF Symbols or custom SwiftUI Shape drawings) for welcome and completion screens
- **Dependencies**: None — purely UI-layer changes using existing Theme infrastructure
- **Services affected**: None
- **Models affected**: None
- **macOS API constraints**: All APIs used are macOS 14+ compatible (existing baseline)
- **Rollback plan**: Revert view file changes; no data migration or service changes involved

## Complexity

**M** (Medium) — Multiple view files to redesign with careful visual attention, but no architectural or data-layer changes. Risk is low since all changes are in the presentation layer.
