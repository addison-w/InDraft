## Context

InDraft is a macOS menu bar app (LSUIElement) that manages Settings and History windows. The current implementation toggles `NSApp.setActivationPolicy(.regular)` when opening windows, temporarily showing a dock icon to enable window activation. This approach is unreliable — sometimes the window doesn't come to front, and the dock icon flashes briefly. The `showDockIcon` user preference further complicates the logic.

The default action hotkeys are already defined as `control+option+1/2/3` in `Constants.swift`. This part needs verification, not code changes.

## Goals / Non-Goals

**Goals:**
- Windows opened from menu bar dropdown always appear in front, reliably
- No dock icon ever — remove the preference and all toggling logic
- Simplify window controller code by removing activation policy dance

**Non-Goals:**
- Changing window appearance, size, or content
- Adding new window types
- Changing hotkey registration mechanism

## Decisions

### Decision 1: Use `orderFrontRegardless()` instead of activation policy toggling

**Choice:** Replace `setActivationPolicy(.regular)` + `makeKeyAndOrderFront(nil)` with `window.orderFrontRegardless()` + `NSApp.activate()`.

**Rationale:** `orderFrontRegardless()` forces a window to front even for LSUIElement/background apps, without needing to become a "regular" app. This eliminates the dock icon flash and the race condition where the policy change doesn't take effect before `makeKeyAndOrderFront`. `NSApp.activate()` is still needed to ensure the app becomes the active app (keyboard focus).

**Alternative considered:** Using `window.level = .floating` — too aggressive, would keep windows above everything. We just need them brought to front on open, not permanently floating.

### Decision 2: Remove `showDockIcon` preference entirely

**Choice:** Remove the `showDockIcon` UserDefaults key, the General Settings toggle, and all conditional `setActivationPolicy` checks.

**Rationale:** The user explicitly wants no dock icon. The current toggle adds complexity to every window controller (checking the preference on close). Removing it simplifies the code and eliminates a class of bugs. The app stays `.accessory` permanently.

### Decision 3: Keep `NSApp.activate()` for keyboard focus

**Choice:** Call `NSApp.activate()` after `orderFrontRegardless()` to ensure the app receives keyboard focus.

**Rationale:** `orderFrontRegardless()` brings the window visually to front but doesn't necessarily make the app the key app. `NSApp.activate()` ensures text fields and keyboard navigation work immediately.

## Risks / Trade-offs

- **[Risk] `orderFrontRegardless()` may not work in all macOS versions** → Mitigation: This API has been stable since macOS 10.0. Combined with `NSApp.activate()`, it's the standard pattern for LSUIElement apps.
- **[Trade-off] No dock icon means no Cmd+Tab access to windows** → Accepted: The user explicitly wants this. Windows are accessible via the menu bar dropdown.
- **[Risk] Removing `showDockIcon` is a breaking preference change** → Mitigation: Few users likely rely on this. The preference simply stops being read; no migration needed.
