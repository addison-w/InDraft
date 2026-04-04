## ADDED Requirements

### Requirement: HugeiconsSwiftUI package dependency
The project SHALL include the HugeiconsSwiftUI Swift package as a dependency via Swift Package Manager, pinned to a specific version.

#### Scenario: Package resolves on clean build
- **WHEN** the project is built from a clean state
- **THEN** SPM resolves and fetches the HugeiconsSwiftUI package without errors

#### Scenario: Package version is pinned
- **WHEN** the package dependency is declared in project.yml
- **THEN** it SHALL specify an exact version or version range to prevent unexpected updates

### Requirement: Centralized icon mapping via AppIcon enum
The app SHALL provide a centralized `AppIcon` enum in `InDraft/Utilities/IconProvider.swift` that maps semantic icon names to Hugeicons views.

#### Scenario: All app icons are defined
- **WHEN** a developer needs to use an icon in any view
- **THEN** they SHALL reference an `AppIcon` case rather than using Hugeicons identifiers directly

#### Scenario: AppIcon provides a SwiftUI view
- **WHEN** an `AppIcon` case's `.view` property is accessed
- **THEN** it SHALL return the corresponding Hugeicons SwiftUI view

#### Scenario: AppIcon covers all previously used SF Symbols
- **WHEN** comparing the `AppIcon` enum cases to the 19 previously used SF Symbols
- **THEN** every SF Symbol SHALL have a corresponding `AppIcon` case

### Requirement: NSImage rendering for AppKit contexts
The `AppIcon` enum SHALL provide a method to render any icon as an `NSImage` for use in AppKit contexts (specifically `NSStatusItem`).

#### Scenario: Render icon as NSImage
- **WHEN** `AppIcon.nsImage(size:color:)` is called
- **THEN** it SHALL return a non-nil `NSImage` of the requested size

#### Scenario: NSImage respects display scale
- **WHEN** rendering an icon as NSImage on a Retina display
- **THEN** the renderer SHALL use the screen's backing scale factor for crisp rendering

#### Scenario: NSImage supports custom color
- **WHEN** `AppIcon.nsImage(size:color:)` is called with a specific color
- **THEN** the resulting image SHALL render the icon in that color

### Requirement: No SF Symbol references remain
After migration, the codebase SHALL contain zero references to SF Symbol names for icons that have been replaced.

#### Scenario: Clean migration
- **WHEN** searching the codebase for `Image(systemName:` and `NSImage(systemSymbolName:`
- **THEN** zero results SHALL be found for any of the 19 previously used SF Symbol names
