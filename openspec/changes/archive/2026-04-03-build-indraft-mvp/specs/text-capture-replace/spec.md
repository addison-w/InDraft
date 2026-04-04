## ADDED Requirements

### Requirement: Primary text capture via Accessibility API
The app SHALL capture selected text from the focused UI element using the macOS Accessibility API (AXUIElement) as the primary capture method.

#### Scenario: Capture selected text from supported app
- **WHEN** a transformation is triggered AND the focused app supports AX selected text reading
- **THEN** the app reads the selected text via `kAXSelectedTextAttribute` within 500ms

#### Scenario: No text selected
- **WHEN** a transformation is triggered AND no text is selected in the focused app
- **THEN** the app shows a "No text selected" notification AND makes no API call

### Requirement: Clipboard fallback for text capture
When Accessibility API capture fails or returns empty, the app SHALL automatically fall back to clipboard-based capture: save current clipboard, simulate Cmd+C, read clipboard, restore original clipboard.

#### Scenario: AX capture fails, clipboard fallback succeeds
- **WHEN** AX text capture returns empty or fails AND the focused app supports Cmd+C
- **THEN** the app saves clipboard contents, simulates Cmd+C, reads the selected text from clipboard, and restores original clipboard within 5 seconds

#### Scenario: Both capture methods fail
- **WHEN** AX capture fails AND clipboard capture fails
- **THEN** the app shows "Could not read selected text" notification AND makes no clipboard modifications AND makes no API call

### Requirement: Primary text replacement via Accessibility API
The app SHALL replace selected text in the focused UI element using the macOS Accessibility API as the primary replacement method.

#### Scenario: Replace text in supported app
- **WHEN** transformed text is ready AND the focused app supports AX text writing
- **THEN** the app writes the transformed text via `kAXSelectedTextAttribute` AND cursor is positioned at end of replaced text

### Requirement: Clipboard fallback for text replacement
When Accessibility API replacement fails, the app SHALL fall back to clipboard-based replacement: place transformed text on clipboard, simulate Cmd+V, then restore original clipboard.

#### Scenario: AX replacement fails, clipboard fallback succeeds
- **WHEN** AX text replacement fails AND the focused app supports Cmd+V
- **THEN** the app places transformed text on clipboard, simulates Cmd+V, and restores original clipboard within 30 seconds

#### Scenario: Both replacement methods fail
- **WHEN** AX replacement fails AND clipboard replacement fails
- **THEN** the app copies the transformed text to clipboard AND shows "Result copied to clipboard — paste manually" notification

### Requirement: Clipboard integrity preservation
The app SHALL never leave the clipboard in a modified state for more than 30 seconds after any clipboard-based operation.

#### Scenario: Clipboard restored after fallback capture
- **WHEN** clipboard fallback is used for text capture
- **THEN** the original clipboard contents are restored within 5 seconds

#### Scenario: Clipboard restored after fallback replacement
- **WHEN** clipboard fallback is used for text replacement
- **THEN** the original clipboard contents are restored within 30 seconds

### Requirement: No unselected content modification
The app SHALL never overwrite, delete, or modify text that was not part of the user's selection.

#### Scenario: Only selected text is replaced
- **WHEN** a replacement occurs (via AX or clipboard)
- **THEN** only the originally selected text is replaced AND all surrounding content remains unchanged
