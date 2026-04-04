# InDraft UI Reimplementation: xAI Design System

## Overview

Reimplement InDraft's entire UI using the xAI design system from DESIGN.md. This transforms the app from a warm, light editorial style to a dark, monospace-driven, brutalist aesthetic.

## Design System Summary

### Core Principles
- **Dark-first**: `#1f2228` background with pure white `#ffffff` text
- **Monospace as luxury**: GeistMono for display headlines and buttons (uppercase + tracked)
- **Zero decorative elements**: No shadows, gradients, or colored accents
- **Sharp architecture**: 0px border-radius default, 4px max for secondary containers
- **Opacity-based depth**: Borders at `rgba(255,255,255,0.1)`, surfaces at `0.03-0.08`

### Color Palette
```
Background:        #1f2228 (warm near-black)
Text Primary:      #ffffff (pure white)
Text Secondary:    rgba(255,255,255,0.7)
Text Tertiary:     rgba(255,255,255,0.5)
Text Quaternary:   rgba(255,255,255,0.3)
Border Default:    rgba(255,255,255,0.1)
Border Strong:     rgba(255,255,255,0.2)
Surface Subtle:    rgba(255,255,255,0.03)
Surface Hover:      rgba(255,255,255,0.08)
Focus Ring:        rgb(59,130,246) at 0.5 opacity
```

### Typography
- **Display/Buttons**: GeistMono, uppercase, 1.4px letter-spacing, weight 300-400
- **Body/Headings**: universalSans fallback to system sans-serif, weight 400
- **Body size**: 16px with 1.5 line-height
- **Section headings**: 30px with 1.2 line-height

### Spacing
- Base unit: 8px
- Scale: 4px, 8px, 12px, 24px, 48px

## Implementation Plan

### Phase 1: Theme Foundation
1. **Theme.swift** - Complete rewrite
   - New color constants matching xAI palette
   - Typography with GeistMono + system sans-serif
   - Sharp corner radius (0px default, 4px secondary)
   - Button styles (white primary, ghost/outlined secondary)
   - Card style with subtle border, no shadow

### Phase 2: Core Components
2. **Button Styles**
   - PrimaryButton: White bg (#ffffff), dark text (#1f2228), 0px radius, GeistMono 14px uppercase
   - GhostButton: Transparent, white text, 1px white 0.2 border, 0px radius
   - Hover behavior: Dim to 0.5 opacity (not brighten)

3. **Input Styles**
   - Transparent background or rgba(255,255,255,0.05)
   - Border: 1px solid rgba(255,255,255,0.2)
   - 0px radius
   - Focus: blue ring at 0.5 opacity

### Phase 3: Views Reimplementation
4. **MenuBarDropdownView** (260px width)
   - Dark header with "INDRAFT" in GeistMono uppercase
   - Provider info row
   - Action rows with monospace hotkey badges
   - Dividers at 0.1 opacity
   - Hover: surface at 0.08 opacity

5. **SettingsView** (700x500)
   - Dark sidebar with white/opacity text
   - Selected tab: brighter text, subtle surface
   - Sharp container corners (4px max)
   - Card content areas with 0.1 border

6. **OnboardingContainerView** (500x450)
   - Dark background throughout
   - Step indicator in GeistMono uppercase
   - Navigation buttons: ghost (BACK) and primary (CONTINUE/FINISH)
   - All step views updated

7. **HistoryWindowView** (650x500)
   - Dark search field
   - Record rows with hover surfaces
   - Expanded detail view
   - Muted footer

8. **PreviewPanelView** (450x300)
   - Two-column comparison on dark
   - Ghost buttons for REJECT/COPY
   - Primary button for ACCEPT
   - Sharp corners

### Phase 4: Testing & Verification
9. Build and run app
10. Take screenshots of each view
11. Verify design matches xAI aesthetic

## Files to Modify

1. `InDraft/Utilities/Theme.swift` - Rewrite
2. `InDraft/Views/MenuBar/MenuBarDropdownView.swift` - Update styling
3. `InDraft/Views/Settings/SettingsView.swift` - Update styling
4. `InDraft/Views/Settings/GeneralSettingsView.swift` - Update styling
5. `InDraft/Views/Settings/ActionsSettingsView.swift` - Update styling
6. `InDraft/Views/Onboarding/OnboardingContainerView.swift` - Update styling
7. `InDraft/Views/Onboarding/WelcomeStepView.swift` - Update styling
8. `InDraft/Views/Onboarding/AccessibilityStepView.swift` - Update styling
9. `InDraft/Views/Onboarding/AddProviderStepView.swift` - Update styling
10. `InDraft/Views/Onboarding/TestConnectionStepView.swift` - Update styling
11. `InDraft/Views/Onboarding/DefaultActionsStepView.swift` - Update styling
12. `InDraft/Views/Onboarding/SampleTransformStepView.swift` - Update styling
13. `InDraft/Views/Onboarding/CompleteStepView.swift` - Update styling
14. `InDraft/Views/History/HistoryWindowView.swift` - Update styling
15. `InDraft/Views/History/HistoryRecordRowView.swift` - Update styling
16. `InDraft/Views/History/HistoryRecordDetailView.swift` - Update styling
17. `InDraft/Views/Preview/PreviewPanelView.swift` - Update styling