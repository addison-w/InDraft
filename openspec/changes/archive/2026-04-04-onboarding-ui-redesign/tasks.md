## 1. Window & Layout Foundation

- [x] 1.1 Update `OnboardingWindowController.swift` window size from 500×450 to 580×540 in `contentRect` and ensure `window.center()` uses `NSScreen.main` for reliable centering
- [x] 1.2 Update `OnboardingContainerView.swift` `.frame(width:height:)` from 500×450 to 580×540
- [x] 1.3 Update `Theme.OnboardingLayout.contentMaxWidth` from 360 to 420

## 2. Navigation Fixes

- [x] 2.1 Fix `OnboardingContainerView.goBack()` — change guard from `currentStep > 1` to `currentStep > 0` so step 1 can navigate back to welcome screen
- [x] 2.2 Remove `skippableSteps` set and SKIP button UI from `OnboardingContainerView`
- [x] 2.3 Ensure CONTINUE is always enabled on steps 2–5 (update `onChange(of: currentStep)` logic) — continue without input advances without saving

## 3. Wabi-Sabi Illustrations

- [x] 3.1 Create `WabiSabiShieldIllustration.swift` — abstract shield/protection motif for accessibility step (SwiftUI Path, matching existing illustration style)
- [x] 3.2 Create `WabiSabiKeyIllustration.swift` — abstract key/connection motif for provider step
- [x] 3.3 Create `WabiSabiPenIllustration.swift` — flowing pen/brush stroke motif for default actions step
- [x] 3.4 Create `WabiSabiSparkIllustration.swift` — abstract transformation/spark motif for sample transform step

## 4. Step Layout Redesign

- [x] 4.1 Redesign `AccessibilityStepView` — centered layout with `WabiSabiShieldIllustration` above title, centered title/description, instruction card centered below, generous vertical spacing
- [x] 4.2 Redesign `AddProviderStepView` — centered layout with `WabiSabiKeyIllustration`, show TEST CONNECTION button always (disabled when fields incomplete), remove conditional `if allFieldsFilled` wrapper, improve field spacing for 580×540 window
- [x] 4.3 Redesign `DefaultActionsStepView` — centered layout with `WabiSabiPenIllustration` above title, centered title/description, action card centered below
- [x] 4.4 Redesign `SampleTransformStepView` — centered layout with `WabiSabiSparkIllustration` above title, centered composition with text editor and transform button

## 5. Verification

- [x] 5.1 Build the project and verify no compilation errors
- [ ] 5.2 Walk through all 6 screens visually: welcome → accessibility → provider → actions → sample → complete, verify illustrations render, back navigation works from step 1 to welcome, no skip button visible, no overflow on provider step
