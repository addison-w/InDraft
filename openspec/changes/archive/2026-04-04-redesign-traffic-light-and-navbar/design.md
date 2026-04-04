## Context

InDraft currently uses system-standard traffic light buttons in its Settings and History windows, which creates visual inconsistency with the app's warm, minimal aesthetic. The Settings screen also uses a segmented control for navigation that feels heavy compared to the clean, editorial design elsewhere in the app.

### Current State
- Settings and History windows inherit macOS default titlebar with traffic lights
- Settings navigation uses `Picker` with `segmented` style (visual pill segments)
- Window chrome is opaque with standard macOS styling

### Target State
- Custom window chrome with warm monochrome color palette
- Minimalist tab navigation using typographic hierarchy
- Unified visual language across all windows

## Goals / Non-Goals

**Goals:**
- Replace system traffic lights with custom window controls matching the app's warm monochrome palette
- Redesign Settings navigation to use clean typographic tabs with subtle active indicators
- Maintain all existing window functionality (drag, resize, minimize, close)
- Ensure window controls remain accessible and discoverable

**Non-Goals:**
- No changes to window management behavior or keyboard shortcuts
- No changes to window dimensions or content layout
- No changes to the menu bar dropdown UI
- No functional changes to navigation (same tabs, same content)

## Decisions

### 1. Custom Window Chrome Implementation
**Decision:** Use `NSWindow` with `titlebarAppearsTransparent = true` and add custom SwiftUI view for window controls.

**Rationale:**
- Gives full control over the appearance while maintaining native window behavior
- SwiftUI provides consistent styling with the rest of the app
- Can match the "Technical Curator" aesthetic precisely

**Implementation approach:**
- Create `WindowChromeView` SwiftUI component with three circular buttons
- Colors: Close (#FF5F57, hover), Minimize (#FFBD2E, hover), Zoom (#28C840, hover)
- Default state: `#E8E8E8` (subtle gray circles)
- Size: 12x12pt circles with 8pt spacing (matching macOS convention)
- Icons (SF Symbols) appear on hover: `xmark`, `minus`, `arrow.up.left.and.arrow.down.right`

**Alternative considered:** Custom `NSThemeFrame` subclass — rejected due to complexity and AppKit bridging overhead.

### 2. Settings Navigation Redesign
**Decision:** Replace segmented `Picker` with custom `HStack` of text buttons using typographic active state.

**Rationale:**
- Segmented control creates visual weight with its pill background
- Text-based tabs align with editorial minimalism
- Underline active indicator follows modern macOS design patterns (e.g., Xcode tabs)

**Implementation approach:**
- Horizontal stack of text buttons for each tab (General, Providers, Actions, Hotkeys, About)
- Active state: `Charcoal` text with 2pt underline in `Pale Blue`
- Inactive state: `Light Charcoal` text (`#787774`)
- Font: `Inter` 13pt, medium weight
- Spacing: 24pt between tabs
- Animation: Smooth 200ms transition for underline and color changes

**Alternative considered:** macOS `TabView` with `.tabStyle(.sidebar)` — rejected as it's too heavy for this use case.

### 3. Window Title Integration
**Decision:** Integrate window title into the content area rather than using system title bar.

**Rationale:**
- Creates clean, unified header with custom chrome
- Allows consistent spacing and typography control

**Implementation approach:**
- Add title text (e.g., "Settings", "History") in top content area
- Position below custom window controls with appropriate padding
- Use `Manrope` 24pt, semibold for titles

## Risks / Trade-offs

**Risk:** Custom window controls may not match user expectations for macOS apps
- **Mitigation:** Use standard positioning (top-left) and familiar hover states (colored circles); include tooltips for accessibility

**Risk:** `titlebarAppearsTransparent` removes default drag area
- **Mitigation:** Add `contentView` with explicit drag gesture or use `NSWindow` delegate method `mouseDragged` in a custom title bar view

**Risk:** Breaking changes in future macOS versions
- **Mitigation:** All changes are visual only; core window management remains standard `NSWindow`

**Risk:** Reduced accessibility compared to system controls
- **Mitigation:** Add proper accessibility labels and actions to custom controls; ensure VoiceOver support

**Trade-off:** Custom chrome requires maintaining platform-specific code
- **Acceptance:** This is a macOS-only app, so platform-specific code is expected and acceptable

## Migration Plan

1. **Phase 1**: Update `SettingsWindowController` and `HistoryWindowController` to enable transparent titlebar
2. **Phase 2**: Create `WindowChromeView` component with all three buttons
3. **Phase 3**: Integrate custom chrome into Settings and History window root views
4. **Phase 4**: Replace Settings navigation `Picker` with custom tab component
5. **Phase 5**: Adjust content padding to accommodate removed title bar

**Rollback:** Revert `titlebarAppearsTransparent` to `false` and restore original `Picker` style.

## Open Questions

- Should window controls always show colored state or only on hover? (Current decision: hover only for minimalism)
- Should inactive tabs have hover feedback? (Current decision: subtle opacity shift)
- Any impact on full-screen behavior? (Need to test)
