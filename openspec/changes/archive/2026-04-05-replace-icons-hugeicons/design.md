## Context

InDraft uses 19 unique SF Symbols across 16 view files (31 SwiftUI `Image(systemName:)` + 5 AppKit `NSImage(systemSymbolName:)`). The app has a hybrid SwiftUI/AppKit architecture — most views are SwiftUI, but the menu bar status item (`MenuBarController`) uses AppKit's `NSStatusItem` which requires `NSImage`.

The HugeiconsSwiftUI package provides 4,000+ stroke-rounded icons as native SwiftUI `View` types (not `Image`). This is a key architectural difference from SF Symbols: Hugeicons are SwiftUI path-based views, not symbol images.

## Goals / Non-Goals

**Goals:**
- Replace all SF Symbol references with visually equivalent Hugeicons
- Maintain identical UX behavior (dynamic icons for states, actions, toasts)
- Ensure menu bar status item works correctly with Hugeicons rendered as NSImage
- Keep a single icon mapping reference for easy future icon changes

**Non-Goals:**
- Changing icon sizing, colors, or layout
- Modifying the Theme system
- Replacing the custom bouncing ball processing animation
- Adding animated icon transitions
- Using multiple Hugeicons styles (stroke-rounded only)

## Decisions

### Decision 1: Create a centralized `IconProvider` enum

**Choice:** Create a new `InDraft/Utilities/IconProvider.swift` file with a centralized enum that maps semantic icon names to Hugeicons views.

**Rationale:** Currently, SF Symbol names are scattered as string literals across 16 files. Centralizing the mapping means:
- One place to update if an icon name changes
- Type-safe icon references (no string typos)
- Easy to swap icon libraries again in the future

**Alternative considered:** Direct inline replacement (find/replace `Image(systemName: "gear")` → `Hugicons.settings01`). Rejected because scattered string literals are the current pain point — centralizing is a small investment that prevents the same problem recurring.

```swift
import SwiftUI
import HugeiconsSwiftUI

enum AppIcon {
    case settings, actions, providers, history
    case add, close, search, copy, dragHandle
    case chevronRight, chevronDown
    case eye, eyeSlash
    case success, error, warning, info
    case edit, menu
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .settings: Hugicons.settings01
        case .actions: Hugicons.flash01
        case .providers: Hugicons.puzzlepiece01
        // ... etc
        }
    }
}
```

### Decision 2: NSImage rendering via ImageRenderer for AppKit contexts

**Choice:** Use SwiftUI's `ImageRenderer` (macOS 13+) to convert Hugeicons views into `NSImage` for `MenuBarController`.

**Rationale:** `MenuBarController` uses `NSStatusItem.button.image` which requires `NSImage`. Since Hugeicons are SwiftUI views (not `Image`), we need a bridge. `ImageRenderer` is Apple's official SwiftUI → image bridge, available since macOS 13 (our minimum is macOS 14).

**Alternative considered:** Using `NSHostingView` to render into a bitmap context. Rejected — more complex and `ImageRenderer` is purpose-built for this.

```swift
extension AppIcon {
    func nsImage(size: CGFloat, color: NSColor = .labelColor) -> NSImage {
        let renderer = ImageRenderer(
            content: self.view
                .foregroundStyle(Color(nsColor: color))
                .frame(width: size, height: size)
        )
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2.0
        return renderer.nsImage ?? NSImage()
    }
}
```

### Decision 3: SF Symbol → Hugeicons mapping strategy

**Choice:** Map based on semantic meaning, not visual similarity. Each SF Symbol maps to the closest Hugeicons equivalent by function.

| SF Symbol | Hugeicons Equivalent | Context |
|-----------|---------------------|---------|
| `pencil.line` | `edit01` | Menu bar idle state |
| `checkmark` | `checkmarkCircle02` | Success states |
| `checkmark.circle.fill` | `checkmarkCircle02` | Success confirmation |
| `xmark` | `cancel01` | Close button |
| `xmark.circle.fill` | `cancelCircle` | Error states |
| `exclamationmark.triangle` | `alert02` | Permission warning |
| `exclamationmark.circle` | `alertCircle` | Error state |
| `plus` | `add01` | Add items |
| `gear` | `settings01` | Settings reference |
| `gearshape` | `settings01` | Settings tab |
| `bolt.fill` | `flash01` | Actions tab |
| `puzzlepiece.fill` | `puzzlepiece` | Providers tab |
| `clock` | `clock01` | History tab |
| `magnifyingglass` | `search01` | Search field |
| `eye` | `view` | Show password |
| `eye.slash` | `viewOff` | Hide password |
| `doc.on.doc` | `copy01` | Copy to clipboard |
| `lock.shield` | `shieldKey` | Privacy note |
| `line.3.horizontal` | `dragDropVertical` | Drag handle |
| `chevron.right` | `arrowRight01` | Expandable indicator |
| `chevron.down` | `arrowDown01` | Expanded indicator |
| `clock.arrow.circlepath` | `clockRewind` | History empty state |
| `ellipsis` | `moreHorizontal` | Menu button |

*Note: Exact Hugeicons identifiers will be verified against the package at implementation time. The mapping above uses likely names based on the naming convention.*

### Decision 4: No new protocols or services needed

**Choice:** This is a purely view-layer change. No protocols, services, or AppCoordinator modifications needed.

**Rationale:** Icons are UI concerns. The `AppIcon` enum is a simple value type, not a service. `MenuBarController` already owns the status item image — it just changes where the image comes from.

## Testability

- **Unit tests:** Test `AppIcon.nsImage()` returns a non-nil, non-zero-size image for each icon case
- **Visual verification:** Build and run, inspect each view to confirm icons render correctly
- **Menu bar verification:** Confirm status item icons display at correct size and respond to state changes
- **No mock implementations needed** — `AppIcon` is a simple enum with no dependencies

## AppKit/SwiftUI Bridging

The only bridging point is `MenuBarController.swift`, which needs `NSImage` for `NSStatusItem`. The `AppIcon.nsImage()` extension handles this via `ImageRenderer`. No changes to `AppCoordinator` or window controllers are needed.

## Risks / Trade-offs

- **[Icon naming mismatch]** → Hugeicons Swift identifiers may not exactly match web names. Mitigation: verify each identifier against the package source at implementation time; the centralized `AppIcon` enum means only one file to fix.
- **[Visual weight difference]** → Hugeicons stroke style may feel lighter/heavier than SF Symbols at the same size. Mitigation: adjust frame sizes in `AppIcon.view` if needed; centralized mapping makes this a single-file change.
- **[Menu bar rendering quality]** → `ImageRenderer` output quality for small icons (16-18pt). Mitigation: set explicit `scale` to match display backing scale factor; test on both Retina and non-Retina displays.
- **[Package stability]** → `HugeiconsSwiftUI` is a community package (`nicklaus-dev`). Mitigation: pin to a specific version; the centralized enum means swapping libraries only touches one file.
- **[Binary size]** → Adding 4,000+ icon paths increases bundle size even though we use ~20. Mitigation: acceptable trade-off for a menu bar app; if problematic, could vendor only needed icons in the future.
