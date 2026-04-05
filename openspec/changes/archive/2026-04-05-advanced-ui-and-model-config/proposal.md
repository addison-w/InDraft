## Why

InDraft's current UI is light-mode only, limiting usability in low-light environments and failing to meet modern macOS app expectations where dark mode is standard. Additionally, the History window lacks scroll containment for long text entries, making it hard to navigate when transformations involve large blocks of text. Users also cannot visually compare what changed between original and transformed text, reducing the utility of history review. Finally, all actions share a single global provider/model, preventing cost optimization — users should be able to assign cheaper models to simple tasks (like translation) and reserve more capable models for complex ones (like rewriting).

## What Changes

- **App-wide dark mode support**: Implement a complete dark color scheme across all windows (menu bar dropdown, settings, history, onboarding, preview panel, toasts) that respects macOS system appearance and optionally allows manual override (System / Light / Dark).
- **History scroll containment**: Set a max height on each history record's expanded detail section so that long original/transformed text blocks scroll independently rather than pushing the entire list down.
- **History diff highlighting**: In the transformed text column of history detail view, highlight text differences compared to the original — additions in green, removals in red/strikethrough — so users can instantly see what the AI changed.
- **Per-action model override**: Allow each Action to optionally specify a preferred provider and model, overriding the global active provider. This enables cost-conscious routing (e.g., translation → cheap model, rewriting → capable model).

## Non-goals

- Full theming engine or user-customizable color palettes beyond light/dark.
- Syntax-level diff (word-level diff is sufficient; no need for character-level or AST-level).
- Provider load balancing, fallback chains, or automatic model selection.
- Changing the activation policy or dock icon behavior.

## Capabilities

### New Capabilities
- `dark-mode`: App-wide dark color scheme with system appearance tracking and manual override preference.
- `history-scroll-containment`: Max-height scroll regions for history record detail sections.
- `history-diff-highlight`: Word-level diff highlighting in the transformed text column of history records.
- `per-action-model-override`: Optional provider/model assignment per Action, overriding the global active provider during transformation.

### Modified Capabilities
- `transformation-history`: History detail view gains scroll containment and diff highlighting (UI behavior change).
- `actions-engine`: Action model gains optional provider/model override fields; transform pipeline must respect per-action routing.
- `provider-management`: Provider selection logic changes from global-only to per-action-with-fallback.

## Impact

**Models affected:**
- `Action` — new optional fields: `providerID`, `modelOverride`
- Theme.swift — new dark palette, conditional color resolution

**Services affected:**
- `TransformService` / `AppCoordinator` — provider resolution must check action-level override before falling back to global active provider
- `ProviderService` — must accept model override parameter per-request

**Views affected:**
- All views — color references must use semantic tokens that resolve per appearance
- `HistoryRecordDetailView` — scroll containment + diff rendering
- `ActionsSettingsView` — provider/model picker per action
- `SettingsView` / `GeneralSettingsView` — appearance preference selector

**Dependencies:**
- No new external dependencies. Diff computation can use Swift's `CollectionDifference` or a simple word-level diff algorithm.

**macOS API constraints:**
- `NSAppearance` / `preferredColorScheme` — available macOS 11+, well within the macOS 14+ minimum.

**Complexity estimates:**
- Dark mode: **L** (touches every view, requires systematic color token refactor)
- History scroll containment: **S** (CSS-like max-height + scroll modifier)
- History diff highlighting: **M** (diff algorithm + styled text rendering)
- Per-action model override: **M** (model change + UI picker + pipeline routing)

**Rollback plan:**
- No window management or activation policy changes. All features are additive UI/model changes. Rollback = revert commits. Dark mode can be disabled by removing the appearance preference and reverting to hardcoded light colors.
