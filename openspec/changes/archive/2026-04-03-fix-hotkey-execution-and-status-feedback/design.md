## Context

The hotkey-triggered transformation pipeline (`HotkeyService` → `AppCoordinator.handleHotkeyPress` → `TransformService.execute`) is correctly wired and functional. However, users perceive it as broken because:

1. **Duplicate type definitions**: `ToastManager.swift` defines `ToastType` (simple enum) and `ToastManager` (uses `ToastItem`). `ToastView.swift` defines `ToastType` (enum with associated values) and another `ToastManager` (uses `ToastType`). The `AppCoordinator` calls `toastManager.show(.error("msg"))` which matches the `ToastView.swift` version's factory pattern, but the duplicate types create ambiguity.
2. **Toast never rendered**: `ToastView` exists as a SwiftUI view but is never mounted in any view hierarchy — no window, no overlay, no scene presents it.
3. **Static processing icon**: `MenuBarController.updateIcon(for:)` swaps to a static `arrow.trianglehead.2.counterclockwise` image during processing — no animation to convey active work.

## Goals / Non-Goals

**Goals:**
- Consolidate toast infrastructure into a single, canonical implementation
- Display toast notifications to the user via a floating overlay window near the menu bar
- Animate the menu bar icon during processing state
- Ensure the dropdown reflects live status during transformation

**Non-Goals:**
- Modifying the hotkey registration or execution pipeline
- Changing `TransformService`, `TextCaptureService`, or `TextReplaceService` logic
- Adding `UNUserNotificationCenter` system notifications (post-MVP)
- Changing the data model or persistence layer

## Decisions

### Decision 1: Consolidate toast types — keep `ToastView.swift` version, delete `ToastManager.swift`

**Choice**: Remove `InDraft/Services/ToastManager.swift` entirely. The `ToastView.swift` version is the correct one — it uses associated values (`ToastType.success(String)`) which match how `AppCoordinator` calls `toastManager.show(.success("Text replaced"))`.

**Why not the other way**: The `ToastManager.swift` version uses a two-type system (`ToastItem` + simple `ToastType` enum) which doesn't match the call sites. The `ToastView.swift` version is simpler and already paired with its SwiftUI view.

### Decision 2: Toast overlay via borderless `NSPanel` (not SwiftUI Scene)

**Choice**: Create a `ToastOverlayController` that manages a borderless, non-activating `NSPanel` positioned near the menu bar status item. The panel hosts `ToastView` via `NSHostingView`.

**Why NSPanel over SwiftUI Scene**: 
- SwiftUI `Scene` types (Window, MenuBarExtra) don't support transparent, non-activating overlays
- `NSPanel` with `.nonactivatingPanel` style mask ensures the user's active app retains focus (critical for text replacement flow)
- `NSPanel` with `.floating` level ensures visibility above other windows
- This matches the existing pattern used by `PreviewPanelController`

**Why not NSPopover**: Popovers are anchored and dismiss on outside click. Toasts should float independently and auto-dismiss.

**Alternatives considered**:
- `NSWindow.Level.floating` plain window — works but `NSPanel` with `nonactivatingPanel` is the idiomatic choice for utility overlays
- System `UNUserNotification` — too heavyweight, requires notification permission, and can't be styled to match the design system

**AppKit/SwiftUI bridging**: `NSHostingView` wraps `ToastView` (SwiftUI) inside the `NSPanel` (AppKit). The `ToastManager` (ObservableObject) drives show/hide via Combine observation in the controller.

### Decision 3: Animated processing icon via `Timer`-driven symbol swap

**Choice**: When `AppState.status` transitions to `.processing`, start a `Timer` that cycles through 2-3 SF Symbol frames (e.g., `circle.dotted`, `circle.dotted` rotated via `NSImage` transforms, or a sequence like `ellipsis` → `ellipsis.circle` → `ellipsis.circle.fill`). Stop the timer on any state transition away from `.processing`.

**Why not CAAnimation on NSStatusBarButton**: The `NSStatusBarButton.image` doesn't support Core Animation layers directly. Timer-based frame swapping is the standard approach for menu bar icon animation (used by Xcode, Docker, etc.).

**Refined approach**: Use SF Symbol `arrow.trianglehead.2.counterclockwise` with a rotation transform applied to a cached `NSImage`, cycling through 0°, 120°, 240° at ~4fps. This gives a smooth spinning effect with a single symbol.

### Decision 4: Toast positioning relative to status item

**Choice**: Position the toast panel directly below the menu bar status item button, offset by 8pt. Get position from `statusItem.button.window.frame`.

**Why**: Toasts should appear near the trigger point (menu bar icon) per the PRD. This matches user expectation — the icon changes state and the toast appears nearby.

### Decision 5: Toast design — minimalist, editorial style

**Choice**: Follow the existing design system ("The Technical Curator"):
- Background: `Theme.Colors.cardBackground` (warm bone tonal shift)
- No hard borders — use `Theme.Colors.cardBorder` ghost border with `0.5` opacity
- Typography: Inter body at 12pt for message, SF Symbol at 14pt for icon
- Elevation: Ambient diffusion shadow (`blur: 12, y: 4, opacity: 0.08`) — not a heavy drop shadow
- Corner radius: `Theme.Radius.md`
- Compact: single-line layout, horizontal icon + message
- Width: auto-sizing with max 280pt, min 160pt
- Animation: fade in (0.2s ease), fade out (0.15s ease)

## Risks / Trade-offs

**[Risk] Toast panel may appear behind full-screen apps** → Use `NSWindow.Level.statusBar` (one level above floating) to ensure visibility. Test with full-screen Safari/Chrome.

**[Risk] Timer-based animation may not be smooth enough** → 4fps is sufficient for a menu bar spinner. If janky, increase to 8fps. The visual impact is subtle — a slowly rotating arrow.

**[Risk] Removing `ToastManager.swift` may break other imports** → Grep confirms no other file imports from `ToastManager.swift` specifically; `AppCoordinator` uses the `ToastType` with associated values pattern, confirming it resolves to the `ToastView.swift` version.

**[Trade-off] NSPanel complexity vs. simplicity** → An NSPanel adds ~60 lines of controller code, but it's the correct tool for non-activating overlays. The alternative (doing nothing and hoping SwiftUI scenes work) would violate the "must not steal focus" requirement.

## Testability

- **ToastManager**: Already `@MainActor` + `ObservableObject` — unit test `show()` / `dismiss()` via XCTest, verify `currentToast` publishes expected values
- **ToastOverlayController**: Integration test — verify panel appears at correct position, verify `isVisible` tracks `currentToast != nil`
- **MenuBarController animation**: Test that timer starts on `.processing` and stops on `.idle`/`.success`/`.error` — mock `AppState` and observe timer lifecycle
- **Mock implementations needed**: None new — existing `MockHotkeyService` and mock services suffice. `ToastManager` is already concrete (no protocol needed since it's a simple state holder)

## AppCoordinator Changes

No changes to `AppCoordinator` logic. The coordinator already calls `toastManager.show(...)` correctly. The fix is that `ToastManager` will now resolve to a single unambiguous type, and the `ToastOverlayController` will actually render the toasts.

## Window Controller Changes

New `ToastOverlayController` class following the existing pattern of `PreviewPanelController`, `SettingsWindowController`, and `HistoryWindowController`:
- Owned by `MenuBarController` (which already owns the status item and can provide positioning)
- Observes `ToastManager.currentToast` via Combine
- Shows/hides the `NSPanel` with fade animation

## Open Questions

- Should the toast panel have a click-to-dismiss gesture? **Tentative yes** — tap anywhere on the toast to dismiss early.
- Should processing animation stop during preview mode (output behavior = preview)? **Yes** — `AppState` transitions to `.idle` for preview, which naturally stops the animation.
