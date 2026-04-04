## Context

InDraft's onboarding flow (7 steps) is functionally complete but visually basic. The existing views use ad-hoc styling rather than the refined Theme.swift design system established across Settings and MenuBar views. The design reference screenshots (designs/02–06) show the target: a warm, editorial aesthetic with generous whitespace, restrained typography, and sparse wabi-sabi ink-line illustrations.

The current Theme.swift already provides colors, typography, spacing tokens, button styles, and input field styles. The onboarding views simply need to adopt them consistently while adding onboarding-specific visual elements (ink-line art, step indicators, transition animations).

No services, models, or window management changes are needed — this is purely a view-layer redesign.

## Goals / Non-Goals

**Goals:**
- All onboarding views use Theme tokens exclusively (zero hardcoded values)
- Welcome and Complete screens feature wabi-sabi ink-line illustrations drawn as SwiftUI Shapes (no raster assets)
- Consistent step indicator (dot pagination) across all steps
- Smooth, gentle transitions between steps (Theme.Animation.gentle: 300ms)
- Typography hierarchy follows the design references: pageTitle for headlines, body for descriptions, label/allCaps for metadata
- Form fields (AddProviderStep) use Theme.InputFieldStyle
- Buttons use Theme.PrimaryButtonStyle and Theme.SecondaryButtonStyle
- Layout matches design references: centered content, generous vertical spacing

**Non-Goals:**
- Changing step logic, navigation flow, or skip rules
- Modifying AppCoordinator or OnboardingWindowController
- Adding new services or protocols
- Changing SwiftData models
- Custom AppKit views — staying pure SwiftUI

## Decisions

### 1. Ink-line illustrations as SwiftUI Shape/Path drawings

**Decision**: Draw wabi-sabi illustrations using SwiftUI `Path` and `Shape` rather than bundled image assets.

**Rationale**: Vector paths scale perfectly on all displays, stay resolution-independent, can be animated with SwiftUI transitions, and avoid asset catalog bloat. The wabi-sabi aesthetic calls for simple, imperfect ink strokes — achievable with a small number of path segments and slight randomization in stroke width.

**Alternative considered**: Bundled SVG/PDF assets — rejected because they can't be animated as naturally and add build complexity for simple line art.

### 2. Step indicator as minimal dot pagination

**Decision**: Use a horizontal row of small circles (6px diameter, Theme.Spacing.xs gap) where the current step is filled with Theme.Colors.textPrimary and others use Theme.Colors.divider.

**Rationale**: Matches the design reference (designs/02 shows three dots). Keeps the interface calm and uncluttered. The dots are purely decorative — step count and progress are already tracked by OnboardingContainerView's @AppStorage.

**Alternative considered**: Progress bar or numbered steps — rejected as too heavy for the minimalist aesthetic.

### 3. Step transitions via asymmetric SwiftUI transitions

**Decision**: Use `.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity))` with `Theme.Animation.gentle` duration for forward navigation, reversed for back.

**Rationale**: Creates a natural page-turning feel without being distracting. The 300ms gentle duration matches the app's established animation language.

### 4. Onboarding-specific Theme extensions

**Decision**: Add minimal extensions to Theme.swift rather than creating a separate styling file:
- `Theme.Illustrations` namespace with ink stroke color (Theme.Colors.textPrimary at 80% opacity) and stroke width range (1.0–2.0pt)
- `Theme.OnboardingLayout` with content max-width (360pt), illustration height (80pt)

**Rationale**: Keeps all design tokens in one canonical location. The additions are small enough not to bloat Theme.swift.

**Alternative considered**: Separate `OnboardingTheme.swift` — rejected to avoid token fragmentation.

### 5. Form layout for AddProviderStepView

**Decision**: Stack form fields vertically with Theme.Spacing.md gaps, labels as Theme.Typography.allCaps above each field, using Theme.InputFieldStyle. "Test Connection" button sits below the form with Theme.Spacing.xl separation.

**Rationale**: Matches the design reference (designs/04, 05) — clean vertical form with uppercase labels, clear field separation.

## Testability

- **Visual verification**: Build and run the app, trigger onboarding by resetting `onboardingComplete` UserDefault. Take screenshots at each step.
- **Theme compliance**: Grep all onboarding view files to confirm zero hardcoded Color/Font/CGFloat values — all must reference Theme.*.
- **Animation**: Verify step transitions play smoothly at 300ms, no jarring jumps.
- **Accessibility**: VoiceOver navigation through all onboarding steps should read correctly.
- **No protocol or service changes**: Existing unit tests should continue to pass unchanged.

## Risks / Trade-offs

- **[Risk] SwiftUI Path art may look too mechanical** → Mitigation: Use slight stroke width variation and asymmetric compositions to achieve the hand-drawn wabi-sabi feel. Iterate visually.
- **[Risk] Transition animations may feel heavy on older Macs** → Mitigation: Use simple move+opacity (GPU-composited), avoid complex geometry animations. 300ms is fast enough not to feel sluggish.
- **[Risk] Theme.swift modifications could affect other views** → Mitigation: New tokens are namespaced under `Illustrations` and `OnboardingLayout` — no existing tokens are modified.

## AppKit/SwiftUI Bridging

No new bridging required. The onboarding window is already managed by `OnboardingWindowController` (AppKit NSWindow hosting SwiftUI content). All changes are within the SwiftUI view layer hosted inside the existing window.

## Open Questions

- Should the ink-line illustration on the welcome screen depict an upward arrow (as in design reference) or a pen/cursor motif? → Lean toward upward arrow per design reference, can iterate.
- Should step dots be tappable for direct navigation, or purely decorative? → Recommend decorative-only to keep flow linear and prevent users from skipping required steps.
