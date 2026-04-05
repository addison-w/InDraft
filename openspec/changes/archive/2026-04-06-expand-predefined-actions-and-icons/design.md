## Context

InDraft currently ships with 3 predefined actions (Grammar Fix, Rewrite for Clarity, Shorten) defined in `Constants.DefaultActions`, seeded via `SeedData`, and displayed in `DefaultActionsStepView` during onboarding. The icon system in `IconProvider.swift` has 7 action-specific `AppIcon` cases matched by ~7 keyword patterns in `MenuBarDropdownView.iconForAction()`. This change adds 3 more predefined actions and broadens icon coverage for better custom action support.

No services, protocols, or AppCoordinator changes are needed. This is purely additive to constants, seed data, icons, and one onboarding view.

## Goals / Non-Goals

**Goals:**
- Ship 6 predefined actions that demonstrate diverse use cases out of the box
- Update onboarding to showcase all 6 actions with their hotkeys
- Maximize icon coverage so most user-created custom actions get a meaningful icon instead of the generic fallback

**Non-Goals:**
- Custom icon picker UI for actions
- Changes to the Action model, SwiftData schema, or any service protocol
- Changes to hotkey registration system (just assigning new key codes)
- AppKit/SwiftUI bridging changes or window controller modifications

## Decisions

### 1. New action hotkey assignments: Ctrl+Opt+4/5/6

**Rationale**: Continues the existing pattern (Ctrl+Opt+1/2/3) sequentially. Uses `kVK_ANSI_4`, `kVK_ANSI_5`, `kVK_ANSI_6` key codes with the same `controlOptionModifiers`.

**Alternative considered**: No hotkeys for new actions — rejected because consistency with existing actions matters for onboarding.

### 2. Icon matching via expanded keyword patterns (not ML/fuzzy matching)

**Rationale**: The existing `iconForAction()` uses simple `String.contains()` keyword matching, which is fast, predictable, and easy to extend. Adding more keyword→icon mappings in the same pattern keeps the system simple and maintainable.

**Alternative considered**: Fuzzy string matching or NLP-based categorization — rejected as overengineered for this use case. Keyword matching covers the vast majority of action names users would create.

### 3. New AppIcon cases mapped to existing Hugeicons assets

New icon cases and their Hugeicons mappings:
- `.professional` → `Hugeicons.briefcase01` (professional, formal, business)
- `.eli5` / `.simplify` → `Hugeicons.baby01` (ELI5, simplify, simple, easy)
- `.expand` → `Hugeicons.arrowExpand02` (expand, elaborate, extend, lengthen, detail)
- `.email` → `Hugeicons.mail01` (email, mail, letter, message)
- `.chat` → `Hugeicons.bubbleChat` (chat, conversation, dialogue, reply, respond)
- `.code` → `Hugeicons.sourceCode` (code, program, technical, developer, debug)
- `.creative` → `Hugeicons.paintBrush01` (creative, brainstorm, idea, inspire)
- `.formal` → `Hugeicons.graduationCap` (formal, academic, scholarly, essay)
- `.casual` → `Hugeicons.coffee01` (casual, friendly, relaxed, informal)
- `.list` → `Hugeicons.taskDaily01` (list, bullet, outline, organize, format)
- `.heading` → `Hugeicons.heading01` (heading, title, headline)
- `.bold` → `Hugeicons.textBold` (bold, emphasize, highlight, stress)
- `.hashtag` → `Hugeicons.hash01` (hashtag, tag, keyword, seo)
- `.tone` → `Hugeicons.voice` (tone, mood, sentiment, emotion, feel)
- `.magic` → `Hugeicons.magicWand01` (magic, transform, convert, auto)

**Rationale**: Each icon is chosen to be visually distinct and semantically clear. The Hugeicons library has 5000+ assets so we have good coverage. All referenced assets exist in the `hugeicons-swift` package already in use.

### 4. Onboarding layout: 2-column grid for 6 actions

**Rationale**: The current `DefaultActionsStepView` uses a single-column `VStack` with dividers. With 6 actions, a vertical list would be too tall. Instead, keep the same single-column layout but use a more compact row design — reduce vertical padding slightly so all 6 fit comfortably within the onboarding card. The card already has `maxWidth: Theme.OnboardingLayout.contentMaxWidth` constraining it.

**Alternative considered**: 2-column grid — rejected because the keycap display needs horizontal space and a 2-column layout would be too cramped.

## Testability

- **SeedData tests**: Update `SeedDataTests` to verify 6 actions are created with correct names, prompts, and hotkeys
- **Icon matching tests**: Add unit tests for `iconForAction()` covering each new keyword pattern and edge cases (e.g., action name containing multiple keywords)
- **No new protocols or mocks needed** — all changes are to concrete implementations and value types
- **Visual verification**: Build and check onboarding step displays all 6 actions with correct layout

## Risks / Trade-offs

- **[Existing users get 3 actions, not 6]** → `createDefaultActions` is idempotent (skips if any actions exist). Only fresh installs see 6 actions. Users can use "Restore Defaults" to get all 6. This is acceptable — existing users have likely customized their actions.
- **[Icon keyword collisions]** → A name like "Fix email formatting" could match both "fix" (grammarCheck) and "email". Mitigation: order matching from most specific to least specific, and the first match wins (existing behavior).
- **[Hugeicons asset availability]** → All referenced assets must exist in the package. Mitigation: verify each asset name against the generated catalog before implementation.
