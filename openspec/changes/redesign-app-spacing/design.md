# Design: Premium Minimalist Spacing System

## Context

InDraft's current `Theme.Spacing` enum uses tight baseline values (xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32) that create a cramped visual experience. The minimalist-ui skill dictates "massive vertical padding between sections" and "generous internal padding (24px to 40px)" for premium editorial aesthetics. This requires a fundamental shift in spacing philosophy from tight functional layouts to expansive macro-whitespace.

Current issues:
- MenuBarDropdown at 260px width with 6pt row padding feels compressed
- SettingsView sidebar at 140-160px cramps navigation labels
- List items across all views use xs (4pt) spacing
- No section-level padding tokens for visual separation
- Typography lacks line-height guidance for vertical rhythm

## Goals / Non-Goals

**Goals:**
- Establish a spacing scale optimized for premium minimalist aesthetics
- Create semantic spacing tokens for consistent application
- Improve visual breathing room across all primary views
- Define typography line-height ratios for editorial rhythm
- Maintain functional density in data-heavy views (History, Actions list)

**Non-Goals:**
- Color palette changes (separate concern, already correct)
- Font family changes (Manrope/Inter are premium choices)
- Adding new UI components
- Animation/motion system changes
- Changing window dimensions (except OnboardingContainerView)

## Decisions

### 1. Spacing Scale Overhaul

**Decision:** Increase baseline spacing values and add new tokens.

| Token | Current | New | Purpose |
|-------|---------|-----|---------|
| xs | 4pt | 6pt | Micro-spacing (icon gaps, tight inline) |
| sm | 8pt | 12pt | Compact spacing (badge padding, tight groups) |
| md | 12pt | 20pt | Standard spacing (list item gaps, content padding) |
| lg | 16pt | 28pt | Comfortable spacing (section padding, card internal) |
| xl | 24pt | 40pt | Generous spacing (section margins, page padding) |
| xxl | 32pt | 56pt | Section separation |
| xxxl | — | 80pt | Major section breaks |

**Rationale:** The current scale uses Material Design defaults which are too tight for premium editorial aesthetics. The new scale follows the 8pt grid system but with generous multipliers (3x for sm, 5x for md, 7x for lg) that create breathing room while maintaining visual consistency.

**Alternatives considered:**
- Named tokens only (tight, normal, spacious): Rejected—numeric scale provides precise control
- Percentage-based spacing: Rejected—absolute values ensure consistency across screen sizes

### 2. MenuBarDropdown Width Increase

**Decision:** Increase from 260px to 300px.

**Rationale:** At 260px, action names with longer hotkey badges feel cramped. 300px provides comfortable reading width (50-60 characters) matching the optimal line length for readability. The 40px increase (15%) is noticeable but not disruptive to the compact menu bar paradigm.

### 3. List Row Spacing Standardization

**Decision:** All list items must use minimum `md` spacing (20pt) for vertical separation.

**Rationale:** Current `xs` spacing (4pt) creates visual crowding. The minimalist-ui skill specifies "generous vertical padding" with "deliberate whitespace". This applies to:
- HistoryWindowView records
- ActionsSettingsView action rows
- MenuBarDropdownView menu items
- Provider list in settings

### 4. Section Padding Requirements

**Decision:** All primary content areas must have minimum `xl` (40pt) top/bottom padding.

**Rationale:** This creates "macro-whitespace" that separates logical sections, a core principle of premium minimalist design. This applies to:
- ScrollView content padding in settings views
- Onboarding step container padding
- History window list container

### 5. Typography Line-Height

**Decision:** Add explicit line-height values to Theme.Typography.

| Style | Line Height |
|------|-------------|
| headline | 1.2 |
| sectionTitle | 1.3 |
| body | 1.5 |
| label | 1.4 |
| mono | 1.4 |
| caption | 1.4 |
| allCaps | 1.2 |

**Rationale:** Line-height is essential for vertical rhythm. Without explicit values, SwiftUI defaults to tight line spacing that crams lines together. These values follow editorial best practices.

### 6. Card Internal Padding

**Decision:** Add explicit `cardPadding` computed property returning `EdgeInsets(top: 24, leading: 28, bottom: 24, trailing: 28)`.

**Rationale:** Cards currently use inconsistent padding. A dedicated token ensures all cards (actions list, settings sections) have consistent internal spacing. The asymmetric horizontal padding (28pt vs 24pt) accounts for visual weight on the leading edge.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Views feel too sparse | Use semantic tokens—`compact` variants for data-dense areas |
| Breaking change in layout | Incremental rollout by view, visual QA at each step |
| Inconsistent application | Code review checklist for spacing usage |
| Performance on resize | SwiftUI handles padding efficiently; no performance impact |
| User muscle memory disruption | MenuBarDropdown width change is minimal (15%) |

## Migration Plan

### Phase 1: Foundation (Theme.swift)
1. Update `Theme.Spacing` enum with new values
2. Add `Theme.Typography` line-height extensions
3. Add `cardPadding` and `sectionPadding` helpers

### Phase 2: High-Impact Views (by priority)
1. MenuBarDropdownView + MenuBarRowView
2. SettingsView sidebar
3. ActionsSettingsView
4. HistoryWindowView

### Phase 3: Remaining Views
1. OnboardingContainerView
2. ProvidersSettingsView
3. GeneralSettingsView
4. All other settings tabs

### Rollback Strategy
Each phase is independently revertible. If spacing feels too generous in a specific view, revert that view's changes while keeping the Theme foundation. The Theme enum can be partially reverted (specific tokens) if needed.

## Testability

- **Visual QA:** Build and run each modified view, compare before/after screenshots
- **Snapshot Testing:** Consider adding point-in-time snapshots for regression detection
- **Accessibility Testing:** Verify VoiceOver navigation order unchanged
- **Dynamic Type:** Test at different system font sizes (not currently supported, but spacing should not break if added)

## Open Questions

1. Should we introduce semantic spacing tokens (`compact`, `comfortable`, `spacious`) in addition to the numeric scale? 
   - **Recommendation:** Defer until we have real-world usage patterns

2. Should cardPadding be asymmetric (more horizontal) or symmetric?
   - **Recommendation:** Start with symmetric, adjust based on visual QA

3. Should we update SettingsView window dimensions (currently 700×500)?
   - **Recommendation:** Keep current dimensions; spacing improvements work within them