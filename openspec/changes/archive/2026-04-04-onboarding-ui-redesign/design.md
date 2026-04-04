## Context

The onboarding flow consists of a welcome screen (step 0) followed by 5 steps: Accessibility permission, AI Provider setup, Default Actions preview, Sample Transform, and Completion. The window is managed by `OnboardingWindowController` (AppKit `NSWindow` wrapping SwiftUI via `NSHostingController`) at 500×450 with `window.center()`.

Current issues:
- Window at 500×450 is too cramped — the test connection button on step 2 overflows
- Step 1 back button only goes to step 1 (guards `currentStep > 1`), not back to welcome (step 0)
- Skip button on steps 2/3/4 adds visual noise — continue-without-input achieves the same
- Steps 1–4 lack the wabi-sabi illustrations present on welcome and completion screens
- Left-aligned dense layouts on steps 1–2 feel inconsistent with the centered zen aesthetic of welcome/complete

## Goals / Non-Goals

**Goals:**
- Enlarge window to ~580×540 for breathing room; all content fits without overflow
- Center window on primary display using `NSScreen.main`
- Fix back navigation: step 1 can return to welcome (step 0)
- Remove skip button; continue on empty optional fields advances without saving
- Add wabi-sabi line art illustrations to accessibility, provider, default actions, and sample transform steps
- Unify all step layouts toward centered, spacious compositions with generous negative space

**Non-Goals:**
- Changing step order, adding steps, or removing steps
- Modifying provider save/validation logic
- Changing the welcome or completion screens (already match target aesthetic)
- Adding new service protocols or modifying AppCoordinator

## Decisions

### 1. Window size: 580×540

**Rationale**: The current 500×450 causes overflow when test connection UI appears. 580×540 provides ~16% more area, enough for illustrations + form fields + navigation without scrolling. Still feels compact and focused.

**Alternative considered**: 600×600 — too spacious for steps with little content (e.g., default actions). 580×540 is the sweet spot.

**Changes**: `OnboardingWindowController.swift` `contentRect` and `OnboardingContainerView.swift` `.frame(width:height:)`. Update `Theme.OnboardingLayout` constants.

### 2. Back navigation to welcome screen

**Rationale**: Currently `goBack()` guards `currentStep > 1`, preventing return to step 0 (welcome). Change to `currentStep > 0` and show back button on step 1.

**Alternative considered**: Hide back button on step 1 entirely — but user expectation is that back always works.

**Changes**: `OnboardingContainerView.goBack()` — change guard from `> 1` to `> 0`. The navigation bar visibility condition already covers `currentStep > 0` since step indicator shows for steps 1–5.

### 3. Remove skip button, smart continue

**Rationale**: The skip button on steps 2/3/4 is redundant. If the user hasn't entered anything on step 2 (provider), continue should just advance. The existing `goForward(isSkip:)` already handles this — when `providerFieldsFilled` is false, it simply doesn't save. We just need to remove the skip button UI and ensure continue is always enabled on skippable steps.

**Changes**: Remove `skippableSteps` set and skip button from `OnboardingContainerView`. On step 2, continue is always enabled; it saves only if fields are filled. Steps 3/4/5 continue is already always enabled.

### 4. Wabi-sabi illustrations as SwiftUI Shape views

**Rationale**: Existing illustrations (`WabiSabiArrowIllustration`, `WabiSabiCheckmarkIllustration`) are pure SwiftUI Path drawings — no image assets needed. New illustrations follow the same pattern: simple black ink line art with intentional imperfection, asymmetry, and negative space.

New illustrations needed:
- `WabiSabiShieldIllustration` — for accessibility step (abstract shield/protection motif with organic lines)
- `WabiSabiKeyIllustration` — for provider step (abstract key/connection motif)
- `WabiSabiPenIllustration` — for default actions step (flowing pen/brush stroke)
- `WabiSabiSparkIllustration` — for sample transform step (abstract transformation/spark motif)

**Changes**: New files in `InDraft/Views/Onboarding/`, following existing illustration file patterns.

### 5. Centered layout composition for all steps

**Rationale**: Welcome and complete screens use centered VStack with Spacer bookends. Steps 1–4 currently use left-aligned VStacks. Shift to centered composition with the illustration at top, title centered below, content centered, and navigation at bottom. Content cards (instructions, form fields, action list) remain left-aligned within a centered container.

**Changes**: Update `AccessibilityStepView`, `AddProviderStepView`, `DefaultActionsStepView`, `SampleTransformStepView` layouts. Increase `Theme.OnboardingLayout.contentMaxWidth` from 360 to 420 to accommodate the wider window.

### 6. Test connection button always visible on provider step

**Rationale**: Currently hidden behind `if allFieldsFilled`, which causes a layout jump and overflow. Show it always, but disable when fields are incomplete.

**Changes**: `AddProviderStepView` — remove conditional, add `.disabled(!allFieldsFilled)` with dimmed styling.

## Risks / Trade-offs

- **[Risk] Larger window may feel oversized on smaller MacBook screens** → Mitigation: 580×540 is still well under the 1440×900 minimum macOS resolution. Tested ratio feels balanced.
- **[Risk] New illustrations add maintenance surface** → Mitigation: Pure SwiftUI Paths with no external assets. Same pattern as existing illustrations, kept in the same directory.
- **[Risk] Removing skip button could confuse users who expect explicit skip** → Mitigation: Continue button is always enabled on optional steps, so the affordance is preserved. The flow is actually simpler.
- **[Risk] Layout changes could break on different DPI/scale factors** → Mitigation: All sizing uses SwiftUI relative units and Theme constants. No pixel-level positioning.

## Testability

- **Visual verification**: Build and run, walk through all 6 screens, verify illustrations render, navigation works, no overflow
- **Back navigation**: Verify step 1 → welcome works, step 2 → step 1 works
- **Smart continue**: On step 2 with empty fields, verify continue advances without saving a provider
- **Window centering**: Verify window appears centered on primary display
- **No mock implementations needed** — all changes are presentation layer
