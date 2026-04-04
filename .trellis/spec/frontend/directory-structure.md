# Directory Structure

> How UI code is organized in this project.

---

## Overview

InDraft is a macOS menu bar app built with SwiftUI. The UI layer lives under `InDraft/` and is organized by feature area, with shared components and design tokens extracted into reusable modules.

---

## Directory Layout

```
InDraft/
├── App/
│   ├── InDraftApp.swift              # @main entry point, menu bar scene
│   └── AppDelegate.swift             # NSApplicationDelegate for lifecycle hooks
├── Views/
│   ├── MenuBar/
│   │   ├── MenuBarDropdownView.swift # Menu bar dropdown content
│   │   └── MenuBarIconView.swift     # Status icon with state transitions
│   ├── Onboarding/
│   │   ├── WelcomeView.swift
│   │   ├── AccessibilityPermissionView.swift
│   │   ├── AddProviderView.swift
│   │   ├── TestConnectionView.swift
│   │   ├── DefaultActionsView.swift
│   │   ├── SampleTransformationView.swift
│   │   └── OnboardingCompleteView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift        # Tab container
│   │   ├── GeneralSettingsView.swift
│   │   ├── ActionsSettingsView.swift
│   │   ├── ActionEditorView.swift    # Sheet/modal
│   │   ├── ProvidersSettingsView.swift
│   │   ├── ProviderEditorView.swift  # Sheet/modal
│   │   ├── HistorySettingsView.swift
│   │   └── DiagnosticsSettingsView.swift
│   ├── History/
│   │   └── HistoryWindowView.swift
│   ├── Preview/
│   │   └── PreviewPanelView.swift    # Floating panel for preview mode
│   └── Shared/
│       ├── HotkeyRecorderView.swift
│       ├── APIKeyFieldView.swift     # Masked input with show/hide
│       └── ToastView.swift
├── ViewModels/
│   ├── OnboardingViewModel.swift
│   ├── SettingsViewModel.swift
│   ├── ActionEditorViewModel.swift
│   ├── ProviderEditorViewModel.swift
│   ├── HistoryViewModel.swift
│   └── MenuBarViewModel.swift
├── Components/
│   └── DesignSystem/
│       ├── Colors.swift              # Design token colors from DESIGN.md
│       ├── Typography.swift          # Manrope/Inter type scale
│       ├── Spacing.swift             # Spacing scale constants
│       └── ButtonStyles.swift        # Primary, Secondary (pill), Tertiary
├── Models/                           # SwiftData models (see backend/)
├── Services/                         # Business logic (see backend/)
└── Utilities/                        # Shared helpers (see backend/)
```

---

## Module Organization

### Feature-based grouping
Each major feature (Onboarding, Settings, History, MenuBar, Preview) gets its own directory under `Views/`. Each feature directory contains only the SwiftUI views for that feature.

### One view per file
Each SwiftUI `View` struct lives in its own file. File name matches the struct name exactly.

### ViewModel pairing
Each feature that has state logic gets a corresponding ViewModel in `ViewModels/`. ViewModels are `@Observable` classes, not structs.

### Shared components
Reusable UI components that appear in 2+ features go in `Views/Shared/`. Design system primitives go in `Components/DesignSystem/`.

---

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| View files | `PascalCase` + `View` suffix | `ActionEditorView.swift` |
| ViewModel files | `PascalCase` + `ViewModel` suffix | `ActionEditorViewModel.swift` |
| Feature directories | `PascalCase` | `Onboarding/`, `Settings/` |
| Design system files | `PascalCase` by category | `Colors.swift`, `Typography.swift` |
| Preview providers | Inside same file, `#Preview` macro | — |

---

## Anti-Patterns

- **Don't** put business logic in view files — extract to ViewModels or Services
- **Don't** create a `Helpers/` or `Extensions/` grab-bag — put extensions near the types they extend
- **Don't** nest feature directories more than 2 levels deep
- **Don't** put SwiftData model files in `Views/` — they belong in `Models/`
