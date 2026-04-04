# Proposal: Onboarding Flow Improvements

## Why

The onboarding flow blocks users who do not have API keys ready at setup time --- the Add Provider step (Step 2) requires all fields to be filled before the user can proceed, trapping them in onboarding with no escape. Additionally, the Test Connection step (Step 3) exists as a standalone step that adds friction and an unnecessary click-through when it could be an inline action within the provider form. Together these issues make onboarding feel rigid and punishing for users who want to explore the app first and configure a provider later.

## What Changes

- Make the Add Provider step **skippable** --- add a Skip button so users can complete onboarding without configuring a provider and add one later in Settings
- Merge Test Connection UI **into** the Add Provider step as an inline "Test Connection" button with success/failure status display, eliminating the standalone Test Connection step
- Reduce total onboarding steps from 7 (Steps 0--6) to 6 (Steps 0--5) by removing the dedicated test connection step
- Update step numbering and skip-index arrays in OnboardingContainerView to reflect the new step count
- Only persist provider configuration when the user has actually filled in the form fields (not on skip)

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `onboarding-flow`: Add Provider step becomes skippable; Test Connection merges into the provider step as inline UI; standalone Test Connection step is removed; total step count decreases from 7 to 6

## Impact

**Affected Files:**
- `InDraft/Views/Onboarding/OnboardingContainerView.swift` --- step count, step routing, skip-index updates
- `InDraft/Views/Onboarding/AddProviderStepView.swift` --- skip support, inline test connection UI
- `InDraft/Views/Onboarding/TestConnectionStepView.swift` --- removed from step routing (file may remain for reuse of test logic)

**Affected Services:**
- No service-layer changes required; ProviderService test-connection logic is reused as-is from within AddProviderStepView

**Models:**
- No model changes

**Complexity:** S
- Pure View-layer changes within onboarding
- No new protocols, services, or data model modifications
- Reuses existing test-connection logic

**Rollback Plan:**
- Restore original step count (7) and re-add TestConnectionStepView to step routing
- Remove skip button from AddProviderStepView and restore required-field validation gate
- All changes are isolated to the onboarding View layer with no persistence or service impact

## Non-goals

- Changing the visual design or styling of onboarding steps
- Modifying other onboarding steps (Welcome, Accessibility, Default Actions, Sample Transform, Complete)
- Adding new onboarding steps
- Changing ProviderService or KeychainService APIs
- macOS version requirement changes (remains macOS 14+)
