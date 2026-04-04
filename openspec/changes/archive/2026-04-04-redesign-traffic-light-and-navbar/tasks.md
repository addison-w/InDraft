## 1. Window Chrome Infrastructure

- [x] 1.1 Create `WindowChromeView` SwiftUI component with three circular buttons (close, minimize, zoom)
- [x] 1.2 Implement hover states for all three buttons (gray default, colored on hover with SF Symbols)
- [x] 1.3 Add accessibility labels to window controls (Close, Minimize, Enter Full Screen)
- [x] 1.4 Add button action handlers that call appropriate NSWindow methods (close, miniaturize, zoom)

## 2. Settings Window Integration

- [x] 2.1 Update `SettingsWindowController` to enable `titlebarAppearsTransparent = true`
- [x] 2.2 Integrate `WindowChromeView` into Settings window root view layout
- [x] 2.3 Ensure window remains draggable with transparent titlebar (add drag gesture or NSToolbar)
- [x] 2.4 Add window title "Settings" below custom chrome using Manrope font
- [x] 2.5 Adjust content padding to accommodate removed system title bar
- [x] 2.6 Test Cmd+W and Cmd+M keyboard shortcuts still work

## 3. History Window Integration

- [x] 3.1 Update `HistoryWindowController` to enable `titlebarAppearsTransparent = true`
- [x] 3.2 Integrate `WindowChromeView` into History window root view layout
- [x] 3.3 Add window title "History" below custom chrome
- [x] 3.4 Adjust content padding for removed title bar
- [x] 3.5 Verify History window maintains proper drag and resize behavior

## 4. Minimalist Settings Navigation

- [x] 4.1 Create `SettingsTabBar` SwiftUI component with text-based tabs (General, Providers, Actions, Hotkeys, About)
- [x] 4.2 Implement active state styling (Charcoal text + Pale Blue underline)
- [x] 4.3 Implement inactive state styling (Light Charcoal text, hover opacity shift)
- [x] 4.4 Add 200ms animation for tab switching (underline and color transitions)
- [x] 4.5 Add accessibility labels and selected states for VoiceOver
- [x] 4.6 Replace existing `Picker` with `segmented` style in `SettingsView` with new `SettingsTabBar`
- [x] 4.7 Ensure tab content persistence works correctly
- [x] 4.8 Add keyboard navigation support (Tab/Arrow keys to focus, Space/Enter to activate)

## 5. Design System Updates

- [x] 5.1 Add window chrome color tokens to Theme.swift (traffic light colors, default gray)
- [x] 5.2 Add navigation tab styling constants (spacing, font, underline height)
- [x] 5.3 Verify all colors match warm monochrome palette specification

## 6. Verification

- [x] 6.1 Build and run the app, verify Settings window shows custom chrome
- [x] 6.2 Verify History window shows custom chrome
- [x] 6.3 Test hover states on all window controls
- [x] 6.4 Test click actions (close, minimize, zoom) on both windows
- [x] 6.5 Verify Settings navigation tabs display correctly
- [x] 6.6 Test tab switching and animations
- [x] 6.7 Verify VoiceOver announces controls correctly
- [x] 6.8 Test keyboard shortcuts (Cmd+W, Cmd+M) still functional
- [x] 6.9 Verify window drag and resize behavior unchanged
- [x] 6.10 Take screenshots for visual confirmation
