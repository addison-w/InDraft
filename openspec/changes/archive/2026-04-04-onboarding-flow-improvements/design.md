# Design: Onboarding Flow Improvements

## Context

InDraft's onboarding flow currently has 7 steps (Steps 0--6). Step 2 (Add Provider) requires all form fields to be filled before the user can proceed, and Step 3 (Test Connection) is a dedicated step that only tests the provider configured in the previous step. This creates two problems: users without API keys are trapped in onboarding, and the test-then-continue pattern adds an unnecessary intermediate step.

The onboarding is implemented in three key files:
- `OnboardingContainerView.swift` --- manages step routing, navigation, skip logic, and the `totalSteps` constant
- `AddProviderStepView.swift` --- provider configuration form with validation
- `TestConnectionStepView.swift` --- standalone test connection step with pass/fail gating

The container view uses a `currentStep` integer and a `skippableSteps` index set to control navigation. The "Continue" button is conditionally enabled based on per-step validation.

## Goals / Non-Goals

**Goals:**
- Allow users to complete onboarding without configuring a provider
- Reduce onboarding friction by merging test connection into the provider step
- Reduce total step count from 7 to 6
- Preserve the ability to test a connection before saving when the user does fill in provider fields

**Non-Goals:**
- Changing the visual design or styling of any onboarding step
- Modifying ProviderService, KeychainService, or any service-layer protocol
- Adding new protocols or mock implementations
- Changing AppCoordinator or window controllers
- Modifying other onboarding steps (Welcome, Accessibility, Default Actions, Sample Transform, Complete)
- AppKit/SwiftUI bridging changes (none required)

## Decisions

### 1. Make Add Provider Step Skippable

**Decision:** Add the provider step index to the `skippableSteps` set in OnboardingContainerView, which enables the existing Skip button for that step.

**Rationale:** The container already has skip infrastructure for Steps 4 and 5 (Default Actions and Sample Transform). Reusing this mechanism requires minimal code change --- just adding the provider step index to the set.

**Alternatives considered:**
- Custom "Skip for now" button with different behavior: Rejected --- the existing skip mechanism already handles navigation correctly, adding a separate button would be inconsistent
- Making provider step disappear entirely: Rejected --- users benefit from the opportunity to configure during onboarding if they have keys ready

### 2. Merge Test Connection Into Add Provider Step

**Decision:** Move the test connection UI (button + status display) from TestConnectionStepView into AddProviderStepView as an inline section below the form fields. The test button appears only when all required fields are filled.

**Rationale:** Testing a connection is a natural sub-action of configuring a provider, not a standalone workflow step. Inline testing provides immediate feedback without forcing a step transition. This pattern is common in settings UIs (e.g., email client account setup).

**Alternatives considered:**
- Keep test as separate step but make it skippable: Rejected --- still adds friction and an extra click for a simple validation action
- Auto-test on field completion: Rejected --- unexpected network calls feel intrusive; explicit user action is better UX

### 3. Conditional Provider Save

**Decision:** Only call `saveProvider()` when the user has filled in the required form fields and taps Continue. When the user taps Skip, no provider is saved.

**Rationale:** Saving an incomplete provider would create invalid data. The skip path should be a clean bypass that leaves the provider list empty, prompting the user to add one later in Settings.

**Alternatives considered:**
- Save partial provider data: Rejected --- an API key-less provider cannot function and would confuse the Settings UI
- Prompt "are you sure?" on skip: Rejected --- adds friction to the skip path, defeating its purpose

### 4. Step Renumbering

**Decision:** Update `totalSteps` from 6 to 5 (steps indexed 0--5) and shift all post-provider step indices down by one.

New step mapping:
| Index | Step | Skippable |
|-------|------|-----------|
| 0 | Welcome | No |
| 1 | Accessibility Permission | No |
| 2 | Add Provider (with inline test) | Yes |
| 3 | Default Actions | Yes |
| 4 | Sample Transform | Yes |
| 5 | Complete | No |

**Rationale:** Removing the standalone test connection step reduces the total from 7 to 6 steps (indices 0--5). The `skippableSteps` set becomes `[2, 3, 4]`.

### 5. Reuse TestConnectionStepView's Test Logic

**Decision:** Extract or inline the test connection logic (API call, status enum, error display) from TestConnectionStepView into AddProviderStepView. The TestConnectionStepView file can remain in the codebase but is no longer referenced in the step routing switch statement.

**Rationale:** Deleting the file risks losing useful reference code and creates a larger diff. Removing it from the routing switch is sufficient to eliminate it as a step. The test logic itself (calling ProviderService to validate the connection) is straightforward to inline.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Users skip provider and cannot use the app | The app already handles no-provider state gracefully --- transformations show an error prompting provider setup. The Complete step and menu bar can hint that a provider is needed. |
| Inline test UI makes the provider step feel crowded | The test section only appears after fields are filled, keeping the initial view clean. The onboarding container is 540x480 with generous padding, providing adequate space. |
| Step index off-by-one errors during renumbering | Careful audit of all step index references in OnboardingContainerView. The switch statement makes missing cases a compile-time error. |
| Onboarding resume logic breaks with new step count | The resume logic saves `currentStep` to UserDefaults. Users mid-onboarding during the update may land on a wrong step. This is an edge case affecting only users who quit mid-onboarding and then update. |

## Testability

- **Unit tests:** Test that `skippableSteps` contains the provider step index (2). Test that `saveProvider()` is not called when skip is triggered with empty fields.
- **UI tests:** Verify the skip button appears on the provider step. Verify tapping skip advances to the Default Actions step. Verify inline test connection button appears only when fields are filled.
- **No new protocols or mocks required** --- all changes are in the View layer using existing ProviderService protocol.

## Open Questions

None --- the scope is well-defined and all decisions are straightforward View-layer changes.
