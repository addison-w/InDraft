## Why

The onboarding flow has several UX issues that create a poor first impression: the welcome screen doesn't center on the display, the window is too small (500×450) causing content overflow when the test connection button appears on the AI provider step, the back button on step 1 doesn't navigate to the welcome screen, the skip button adds unnecessary cognitive load, and the permission/provider steps lack the visual warmth of the welcome screen's wabi-sabi illustrations. The window needs more breathing room and all steps need consistent minimalist styling.

## What Changes

- **Window centering**: Ensure the onboarding window centers on the user's primary display on launch
- **Window size increase**: Enlarge from 500×450 to ~580×540 to give content breathing room and prevent overflow
- **Back button fix**: Allow step 1 (Accessibility) to navigate back to the welcome screen (step 0)
- **Remove skip button**: Replace skip logic with smart continue — if no input provided on optional steps, continue simply advances without saving (same as skip, but less visual clutter)
- **Accessibility step redesign**: Add a wabi-sabi illustration, improve layout with centered composition and better visual hierarchy
- **AI provider step layout fix**: Show test connection button by default, fix overflow bug, improve spacing and field layout for the larger window
- **Consistent wabi-sabi styling across all steps**: Add subtle illustrations to steps that lack them (accessibility, default actions, sample transform), ensure consistent spacing, typography, and composition matching the welcome/complete screens' zen aesthetic
- **Step content layout**: Shift from left-aligned dense layouts to centered, spacious compositions with generous negative space

## Capabilities

### New Capabilities

- `onboarding-ui-polish`: Comprehensive UI/UX polish of the onboarding flow — window sizing, centering, navigation fixes, skip removal, consistent wabi-sabi illustrations, and layout improvements across all steps

### Modified Capabilities

_(none — no spec-level behavioral changes, purely UI/layout refinements)_

## Impact

- **Views affected**: `OnboardingContainerView`, `OnboardingWindowController`, `AccessibilityStepView`, `AddProviderStepView`, `DefaultActionsStepView`, `SampleTransformStepView`, `CompleteStepView`, `WelcomeStepView`
- **Theme changes**: `Theme.OnboardingLayout` constants (window size, content max width)
- **New illustrations**: 2-3 new wabi-sabi SwiftUI illustration views for steps currently lacking them
- **No API/model/service changes** — purely presentation layer

## Non-goals

- Changing onboarding step order or adding/removing steps
- Modifying provider save logic or data model
- Changing accessibility permission detection behavior
- Redesigning the welcome or completion screens (they already match the target aesthetic)

## Rollback Plan

All changes are confined to SwiftUI views and Theme constants. Revert the commit to restore previous onboarding UI. No window management or activation policy changes.

## Complexity

**M** — Multiple view files to update, new illustrations, layout constant changes, but no architectural or service-layer work.
