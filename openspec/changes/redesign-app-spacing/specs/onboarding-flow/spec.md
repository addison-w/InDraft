# Spec: Onboarding Flow (Delta)

## MODIFIED Requirements

### Requirement: Onboarding Container Dimensions
The onboarding window SHALL have dimensions that provide comfortable visual breathing room.

#### Scenario: Onboarding window frame
- **WHEN** the onboarding window is displayed
- **THEN** the frame SHALL be 540×480 points (increased from 500×450)
- **AND** the content area SHALL maintain aspect ratio for centered content

### Requirement: Onboarding Step Content Padding
Each onboarding step SHALL have generous internal padding for visual comfort.

#### Scenario: Step content horizontal padding
- **WHEN** an onboarding step renders its content
- **THEN** the content SHALL have `.padding(.horizontal, Theme.Spacing.xl)` (40pt)

#### Scenario: Step content vertical padding
- **WHEN** an onboarding step renders its content
- **THEN** the content area between header and navigation SHALL have adequate vertical breathing room
- **AND** the content SHALL be centered vertically within available space

### Requirement: Navigation Button Spacing
The navigation buttons at the bottom SHALL have consistent spacing.

#### Scenario: Navigation bar padding
- **WHEN** the navigation bar (BACK/SKIP/CONTINUE) is displayed
- **THEN** the bar SHALL have `.padding(.horizontal, Theme.Spacing.xl)` (40pt)
- **AND** the bar SHALL have `.padding(.bottom, Theme.Spacing.xl)` (40pt)

#### Scenario: Button spacing between items
- **WHEN** multiple navigation buttons are displayed horizontally
- **THEN** the spacing between button groups SHALL be `Theme.Spacing.md` (20pt)

## ADDED Requirements

### Requirement: Step Indicator Spacing
The step indicator ("STEP X OF Y") SHALL have adequate separation from content.

#### Scenario: Step indicator top margin
- **WHEN** the step indicator is displayed
- **THEN** it SHALL have `.padding(.top, Theme.Spacing.xl)` (40pt)
- **AND** the bottom spacing before content SHALL be minimum `Theme.Spacing.lg` (28pt)