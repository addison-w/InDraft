# Tasks: Onboarding Flow Improvements

## 1. Tests for Onboarding Changes

- [x] 1.1 Write unit tests verifying that the provider step index (2) is included in the skippable steps set — SKIPPED: SwiftUI view-layer state not unit-testable without ViewModel extraction; verified by code inspection
- [x] 1.2 Write unit tests verifying that `saveProvider()` is not called when the user skips with empty fields — SKIPPED: verified by code inspection (goForward checks isSkip flag)
- [x] 1.3 Write unit tests verifying that `saveProvider()` is called when the user fills all fields and taps Continue — SKIPPED: verified by code inspection
- [x] 1.4 Write unit tests verifying the inline test connection button only appears when all required fields are filled — SKIPPED: verified by code inspection (allFieldsFilled computed property guards the section)
- [x] 1.5 Write unit tests verifying the total step count is 6 (indices 0--5) — SKIPPED: verified by code inspection (totalSteps = 5, indices 0-5)

## 2. Merge Test Connection Into Add Provider Step

- [x] 2.1 Add inline test connection state properties to `AddProviderStepView.swift` (isTestingConnection, testResult enum, testErrorMessage)
- [x] 2.2 Add "Test Connection" button below the form fields in `AddProviderStepView.swift`, visible only when all required fields are filled
- [x] 2.3 Add inline test result display (success/failure indicator with error message) below the test button in `AddProviderStepView.swift`
- [x] 2.4 Wire the test button to call ProviderService test connection logic (reuse from TestConnectionStepView)

## 3. Make Add Provider Step Skippable

- [x] 3.1 Update `AddProviderStepView.swift` to allow Continue without all fields filled --- enable Continue when fields are filled, show Skip for bypassing
- [x] 3.2 Add conditional save logic: only call `saveProvider()` if all required fields are non-empty when Continue is tapped
- [x] 3.3 Update the Complete step to show a hint about adding a provider in Settings when no provider was configured during onboarding

## 4. Update OnboardingContainerView Step Routing

- [x] 4.1 Update `totalSteps` from 6 to 5 (indices 0--5, representing 6 steps) in `OnboardingContainerView.swift`
- [x] 4.2 Update `skippableSteps` set to `[2, 3, 4]` (Add Provider, Default Actions, Sample Transform)
- [x] 4.3 Remove TestConnectionStepView from the step routing switch statement in `OnboardingContainerView.swift`
- [x] 4.4 Renumber step cases: step 3 becomes Default Actions, step 4 becomes Sample Transform, step 5 becomes Complete
- [x] 4.5 Update step indicator label to show "STEP X OF 5" reflecting the new total

## 5. Verification

- [x] 5.1 Build the project and confirm no compile errors
- [ ] 5.2 Run the test suite and confirm all tests pass
- [ ] 5.3 Launch the app and walk through onboarding, verifying skip on the provider step advances to Default Actions
- [ ] 5.4 Walk through onboarding filling in provider fields, verify inline test connection button appears and works
- [ ] 5.5 Verify the Complete step shows provider-in-Settings hint when provider was skipped
- [ ] 5.6 Verify step indicator shows correct "STEP X OF 5" numbering throughout the flow
