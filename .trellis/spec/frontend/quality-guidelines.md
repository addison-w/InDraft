# Quality Guidelines

> Code quality standards for UI development.

---

## Overview

InDraft targets macOS 14+, Swift 5.9+, Xcode 15+. Code quality is enforced through compiler settings, SwiftLint, and manual review.

---

## Build Settings

- **Swift Strict Concurrency:** `Complete` — all concurrency warnings are errors
- **Treat Warnings as Errors:** enabled for release builds
- **Minimum deployment target:** macOS 14.0

---

## Forbidden Patterns

| Pattern | Why | Fix |
|---------|-----|-----|
| `print()` for debugging | Clutters console, no structure | Use `os.Logger` (see backend/logging-guidelines.md) |
| Hard-coded color literals | Breaks design system | Use tokens from `Colors.swift` |
| `Divider()` between list items | Violates DESIGN.md "No-Line Rule" | Use spacing or background shifts |
| `Color.black` / `Color.white` | DESIGN.md prohibits pure black/white | Use `onSurface` / `surfaceContainerLowest` |
| `AnyView` | Type erasure hurts performance | `@ViewBuilder`, `Group`, or concrete types |
| Raw string literals for user-facing text | Blocks localization | `String(localized:)` |
| Synchronous I/O on main thread | Freezes UI | `async/await` with `.task` modifier |
| Force unwrap (`!`) | Crash risk | Optional binding or defaults |
| Magic numbers for layout | Unmaintainable | Spacing/sizing constants |
| `DispatchQueue.main.async` | Mixes GCD with structured concurrency | `@MainActor`, `MainActor.run` |

---

## Required Patterns

| Pattern | When |
|---------|------|
| `@MainActor` on ViewModels | Always — UI state lives on main thread |
| `#Preview` with realistic data | Every view file |
| Design system tokens for all colors, fonts, spacing | All UI code |
| `async/await` for all asynchronous work | Network, disk, Keychain |
| `guard`/`if let` for optional unwrapping | All optional access |
| Accessibility labels on interactive elements | All buttons, controls |
| `.focusable()` on keyboard-navigable elements | Menus, lists, forms |

---

## Accessibility Requirements

InDraft is a keyboard-driven app that itself relies on the Accessibility API. UI must also be accessible:

- All buttons and controls must have `accessibilityLabel`
- Form fields must have `accessibilityHint` describing expected input
- Status changes (processing, success, error) must post `AccessibilityNotification`
- Tab order must be logical in Settings views
- Menu bar dropdown must be navigable via arrow keys

---

## Testing Requirements

### Unit Tests
- All ViewModels: test state transitions, validation logic, computed properties
- All Services: test business logic with mocked dependencies
- All SwiftData models: test relationships and cascade behavior

### UI Tests (selective)
- Onboarding flow: end-to-end happy path
- Settings: action CRUD operations
- Menu bar: state indicator transitions

### What doesn't need tests
- Pure SwiftUI views with no logic (just layout)
- Design system token definitions
- Preview providers

---

## Code Review Checklist

- [ ] Design system compliance: no raw colors, no borders, correct typography
- [ ] No force unwraps or force casts
- [ ] Async code uses structured concurrency (not Combine, not GCD)
- [ ] ViewModels are `@MainActor @Observable`
- [ ] User-facing strings use `String(localized:)`
- [ ] Interactive elements have accessibility labels
- [ ] No `print()` statements — use `os.Logger`
- [ ] Preview exists and renders with realistic data
- [ ] No secrets (API keys, tokens) in source code
