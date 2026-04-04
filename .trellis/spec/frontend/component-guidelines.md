# Component Guidelines

> How SwiftUI views are built in this project.

---

## Overview

All UI is built with SwiftUI targeting macOS 14+. Views follow the design system defined in `DESIGN.md` — "High-End Utilitarian Editorial" aesthetic with warm bone tones, no hard borders, and typographic hierarchy.

---

## View Structure

Standard structure for a view file:

```swift
import SwiftUI

struct ActionEditorView: View {
    // 1. Environment and bindings
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: ActionEditorViewModel

    // 2. Local state
    @State private var showingDeleteConfirmation = false

    // 3. Body
    var body: some View {
        // View content
    }

    // 4. Extracted subviews (private)
    private var headerSection: some View {
        // ...
    }
}

// 5. Preview
#Preview {
    ActionEditorView(viewModel: .preview())
}
```

### Rules
- Environment/bindings first, then local `@State`, then `body`, then private subviews
- Extract subviews as computed properties when body exceeds ~40 lines
- Use `#Preview` macro (not legacy `PreviewProvider`)
- Every view must have at least one preview

---

## Props / Init Conventions

Views receive dependencies through init parameters, not deep environment injection:

```swift
// GOOD: Explicit dependency
struct ProviderCardView: View {
    let provider: Provider
    let onTest: () -> Void
    let onEdit: () -> Void
}

// BAD: Hidden dependency via environment for domain objects
struct ProviderCardView: View {
    @Environment(ProviderStore.self) var store  // Unclear what this view needs
}
```

**When to use `@Environment`:**
- System values: `\.dismiss`, `\.openWindow`, `\.colorScheme`
- App-wide singletons injected at the root: `AppState`, `NavigationManager`

**When to use init parameters:**
- Data the view displays or edits
- Action callbacks
- Configuration options

---

## Design System Compliance

All views must follow `DESIGN.md`. Key rules:

### Colors
- Use design tokens from `Components/DesignSystem/Colors.swift`, never raw hex literals
- Background: `surface` (#faf9f6 "Warm Bone")
- Primary text: `onSurface` (#2f3430 "Charcoal")
- No pure black (#000) or pure white (#FFF) except `surfaceContainerLowest`

### The No-Line Rule
- **1px solid borders are prohibited** for sectioning
- Use background color shifts between `surface` tiers to create separation
- If a container sits on the same color background, use `outlineVariant` at **15% opacity** ("Ghost Border")

### Typography
- Display/Headlines: **Manrope** font
- Body/Labels: **Inter** font
- Keyboard shortcuts: SF Mono (monospace)

### Elevation
- No traditional drop shadows
- Floating panels: `surface` at 80% opacity + `backdrop-blur` 20px (use `.background(.ultraThinMaterial)`)
- Ambient shadows only: 24px+ blur, 4% opacity, charcoal-derived (never pure black)

### Spacing
- Use spacing scale from `Components/DesignSystem/Spacing.swift`
- Major section separation: `spacing12` (4rem) or `spacing16` (5.5rem)
- Standard border radius: 8px

### Forbidden
- No emojis — use lightweight SVG/SF Symbol icons (2px stroke weight)
- No gradients — depth through flat tonal layering only
- No 100% opaque borders

---

## Composition Patterns

### Sheet/Modal presentation
```swift
.sheet(isPresented: $showingEditor) {
    ActionEditorView(viewModel: editorViewModel)
}
```

### Conditional content
```swift
// Prefer Group or ViewBuilder over AnyView
@ViewBuilder
private var statusIndicator: some View {
    switch status {
    case .idle: IdleIcon()
    case .processing: ProcessingIcon()
    case .success: SuccessIcon()
    case .error: ErrorIcon()
    }
}
```

### List items without dividers
```swift
// Per DESIGN.md: no divider lines between list items
// Use spacing or alternating backgrounds instead
List {
    ForEach(actions) { action in
        ActionRow(action: action)
            .listRowSeparator(.hidden)
            .listRowBackground(
                action.isEven ? Color.surface : Color.surfaceContainerLowest
            )
    }
}
```

---

## Common Mistakes

- **Using `Color.black` or `Color.white`** — always use design token colors
- **Adding `Divider()` between list items** — use spacing or background shifts per DESIGN.md
- **Putting network calls in views** — delegate to ViewModel/Service layer
- **Using `AnyView` for type erasure** — use `@ViewBuilder` or `Group` instead
- **Forgetting `.focusable()` and keyboard navigation** — this is a keyboard-driven app
- **Hard-coding strings** — use `String(localized:)` for user-facing text
