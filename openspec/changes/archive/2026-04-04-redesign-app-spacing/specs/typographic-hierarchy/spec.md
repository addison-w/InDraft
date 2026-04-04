# Spec: Typographic Hierarchy

## ADDED Requirements

### Requirement: Line Height Ratios
The system SHALL define explicit line-height ratios for all typography styles.

| Style | Font Size | Line Height | Use Case |
|-------|-----------|-------------|-----------|
| headline | 28pt | 1.2 | Display headings |
| sectionTitle | 20pt | 1.3 | Section headers |
| body | 13pt | 1.5 | Body text, descriptions |
| label | 11pt | 1.4 | Labels, tags |
| mono | 11pt | 1.4 | Keyboard shortcuts, code |
| caption | 10pt | 1.4 | Small text, hints |
| allCaps | 10pt | 1.2 | Section labels, badges |

#### Scenario: Headline text renders with correct line height
- **WHEN** `Theme.Typography.headline()` is applied to text
- **THEN** the line height SHALL be 1.2× the font size

#### Scenario: Body text renders with generous line height
- **WHEN** `Theme.Typography.body()` is applied to text
- **THEN** the line height SHALL be 1.5× the font size for optimal readability

### Requirement: Typography Line Height API
The Theme.Typography enum SHALL expose line height values alongside font definitions.

#### Scenario: Developer accesses line height for a typography style
- **WHEN** developer calls `Theme.Typography.lineHeight(.body)`
- **THEN** the system SHALL return the correct multiplier (1.5)

#### Scenario: Typography with line height applied to multiline text
- **WHEN** multiline text uses `Theme.Typography.body()` with `.lineSpacing()` applied
- **THEN** the visual line height SHALL match the editorial rhythm specification

### Requirement: Vertical Rhythm Consistency
Typography spacing SHALL maintain vertical rhythm across adjacent text elements.

#### Scenario: Multiple text styles in a VStack
- **WHEN** headline, body, and caption text are stacked vertically
- **THEN** the spacing between them SHALL preserve the baseline grid (multiples of 4pt or 8pt)

#### Scenario: Section title followed by content
- **WHEN** a section title using `sectionTitle()` is followed by body text
- **THEN** the spacing SHALL be minimum `Theme.Spacing.md` (20pt)