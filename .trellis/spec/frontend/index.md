# Frontend Development Guidelines (SwiftUI / UI Layer)

> Best practices for SwiftUI views, ViewModels, and UI components in InDraft.

---

## Overview

This directory contains guidelines for InDraft's UI layer — SwiftUI views, ViewModels, design system components, and observation patterns. InDraft is a macOS 14+ menu bar app built entirely in SwiftUI.

---

## Guidelines Index

| Guide | Description | Status |
|-------|-------------|--------|
| [Directory Structure](./directory-structure.md) | Feature-based organization under `InDraft/` | Filled |
| [Component Guidelines](./component-guidelines.md) | SwiftUI view patterns, DESIGN.md compliance | Filled |
| [Hook Guidelines](./hook-guidelines.md) | `@Observable`, property wrappers, reactive patterns | Filled |
| [State Management](./state-management.md) | SwiftData, ViewModels, @State, @AppStorage, Keychain | Filled |
| [Quality Guidelines](./quality-guidelines.md) | Build settings, forbidden patterns, testing, a11y | Filled |
| [Type Safety](./type-safety.md) | Swift types, enums, concurrency, validation | Filled |

---

## Pre-Development Checklist

Before writing any UI code, read the files relevant to your task:

- **Creating a new view?** → directory-structure.md + component-guidelines.md
- **Adding state or data flow?** → state-management.md + hook-guidelines.md
- **Styling or layout?** → component-guidelines.md (Design System Compliance section)
- **Any UI code?** → quality-guidelines.md (Forbidden Patterns)

Also read `DESIGN.md` at the project root for the full design system specification.

---

**Language**: All documentation should be written in **English**.
