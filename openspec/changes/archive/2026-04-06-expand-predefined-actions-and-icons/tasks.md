## 1. Add New Predefined Actions to Constants

- [x] 1.1 Add `translateToEnglish` to `Constants.DefaultActions` with name "Translate to English", prompt, and hotkey Ctrl+Opt+4 (`kVK_ANSI_4`)
- [x] 1.2 Add `professionalTone` to `Constants.DefaultActions` with name "Professional Tone", prompt, and hotkey Ctrl+Opt+5 (`kVK_ANSI_5`)
- [x] 1.3 Add `eli5` to `Constants.DefaultActions` with name "ELI5", prompt, and hotkey Ctrl+Opt+6 (`kVK_ANSI_6`)

## 2. Update Seed Data

- [x] 2.1 Add the 3 new actions to the `defaults` array in `SeedData.createDefaultActions` with sortOrder 3, 4, 5
- [x] 2.2 Add the 3 new actions to the `defaults` array in `SeedData.restoreDefaultActions`
- [x] 2.3 Update `SeedDataTests` to verify 6 actions are created with correct names, prompts, hotkeys, and sort orders

## 3. Expand AppIcon Enum and Asset Mappings

- [x] 3.1 Add new `AppIcon` cases: `.professional`, `.simplify`, `.expand`, `.email`, `.chat`, `.code`, `.creative`, `.formal`, `.casual`, `.list`, `.heading`, `.bold`, `.hashtag`, `.tone`, `.magic`
- [x] 3.2 Add Hugeicons asset mappings for each new case in the `asset` computed property (verify each asset exists in Hugeicons+Catalog.generated.swift first)

## 4. Expand Icon Keyword Matching

- [x] 4.1 Expand `iconForAction()` in `MenuBarDropdownView` with new keyword→icon mappings, ordered from most specific to least specific:
  - professional/business/corporate/executive → `.professional`
  - eli5/simplify/simple/easy/beginner/basics → `.simplify`
  - expand/elaborate/extend/lengthen/detail/longer → `.expand`
  - email/mail/letter/memo → `.email`
  - chat/conversation/dialogue/reply/respond → `.chat`
  - code/program/technical/developer/debug/script → `.code`
  - creative/brainstorm/idea/inspire/imagine → `.creative`
  - formal/academic/scholarly/essay/thesis/research → `.formal`
  - casual/friendly/relaxed/informal/chill → `.casual`
  - list/bullet/outline/organize/structure → `.list`
  - heading/title/headline/caption → `.heading`
  - hashtag/tag/keyword/seo → `.hashtag`
  - tone/mood/sentiment/emotion/feel → `.tone`
  - magic/transform/convert/auto → `.magic`
- [x] 4.2 Ensure existing matches (rewrite/write, grammar/fix, shorten/condense, paraphrase/rephrase, summarize/summary, translate) remain in place and take priority where appropriate

## 5. Update Onboarding View

- [x] 5.1 Update `DefaultActionsStepView` to reference all 6 predefined actions from `Constants.DefaultActions`
- [x] 5.2 Update the subtitle text from "three built-in actions" to "six built-in actions"
- [x] 5.3 Reduce vertical padding in action rows so all 6 fit comfortably in the onboarding card without scrolling

## 6. Verify

- [x] 6.1 Build the project and confirm no compilation errors
- [x] 6.2 Run existing tests to verify no regressions
- [ ] 6.3 Visually verify the onboarding Default Actions step shows all 6 actions with correct layout
- [ ] 6.4 Visually verify the menu bar dropdown shows correct icons for each predefined action
