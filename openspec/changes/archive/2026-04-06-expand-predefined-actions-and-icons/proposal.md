## Why

InDraft ships with only 3 predefined actions (Grammar Fix, Rewrite for Clarity, Shorten), which limits the out-of-box experience. Users need more diverse starting actions — particularly "Translate to English", "Professional Tone", and "ELI5" — to demonstrate the app's versatility during onboarding. Additionally, the icon matching system only covers ~7 keyword patterns, meaning most custom actions get a generic fallback icon, reducing visual identity in the menu bar dropdown.

## What Changes

- **Add 3 new predefined actions**: "Translate to English" (Ctrl+Opt+4), "Professional Tone" (Ctrl+Opt+5), "ELI5" (Ctrl+Opt+6) to `Constants.DefaultActions` and `SeedData`
- **Update onboarding to show all 6 actions**: Modify `DefaultActionsStepView` to display 6 predefined actions instead of 3, with updated copy
- **Expand icon matching keywords**: Add ~15+ new semantic icon cases to `AppIcon` and broaden keyword matching in `iconForAction()` to cover categories like: tone/formality, explanation/simplification, expansion/lengthening, email/messaging, code/technical, creative/brainstorm, lists/formatting, and more
- **Add corresponding `AppIcon` enum cases**: New icon types mapped to appropriate Hugeicons assets (e.g., `briefcase` for professional, `baby` for ELI5/simplify, `arrowExpand` for expand/elaborate, `bubbleChat` for chat-related, `code` for code-related, etc.)

## Non-goals

- Custom icon selection UI for user-created actions (future feature)
- Changing the Action model schema or data layer
- Modifying hotkey registration logic or key binding system
- Any changes to window management or activation policy

## Capabilities

### New Capabilities
- `expanded-predefined-actions`: Three new default actions (Translate to English, Professional Tone, ELI5) with hotkey bindings and seed data
- `broad-icon-matching`: Extended icon vocabulary in AppIcon and keyword matching to cover a wide range of action name patterns for better custom action support

### Modified Capabilities
- `onboarding-flow`: Update DefaultActionsStepView to display 6 actions instead of 3, with adjusted layout and copy

## Impact

- **Constants.swift**: Add 3 new `DefaultActions` entries with hotkeys Ctrl+Opt+4/5/6
- **SeedData.swift**: Include new actions in `createDefaultActions` and `restoreDefaultActions`
- **IconProvider.swift**: Add ~15 new `AppIcon` cases with Hugeicons asset mappings
- **MenuBarDropdownView.swift**: Expand `iconForAction()` keyword matching with new patterns
- **DefaultActionsStepView.swift**: Show 6 actions, update subtitle text
- **SeedDataTests.swift**: Update tests for 6 default actions
- **Services affected**: None (no service layer changes)
- **Models affected**: None (Action model unchanged, just more seed instances)
- **macOS API constraints**: None (all features work on macOS 14+)
- **Complexity**: **S** — purely additive changes to constants, seed data, icons, and one onboarding view
