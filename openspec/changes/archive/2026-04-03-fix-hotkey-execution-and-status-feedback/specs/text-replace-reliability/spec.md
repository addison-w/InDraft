## ADDED Requirements

### Requirement: Text replacement verification after AX write
After setting `kAXSelectedTextAttribute`, the service SHALL verify the replacement succeeded by re-reading the selected text attribute. If the read-back does not match the written text, the AX strategy SHALL be treated as failed and the service SHALL proceed to the clipboard fallback.

#### Scenario: AX write succeeds and verification passes
- **WHEN** `AXUIElementSetAttributeValue` returns `.success`
- **AND** re-reading `kAXSelectedTextAttribute` returns the written text
- **THEN** the replace result SHALL be `.replaced`

#### Scenario: AX write returns success but verification fails
- **WHEN** `AXUIElementSetAttributeValue` returns `.success`
- **AND** re-reading `kAXSelectedTextAttribute` does NOT match the written text
- **THEN** the AX strategy SHALL be treated as failed
- **AND** the service SHALL fall through to the clipboard fallback strategy

### Requirement: Clipboard fallback includes timing delays for reliability
The clipboard fallback strategy SHALL include brief delays between clipboard write and paste simulation, and between key-down and key-up events, to ensure the target application receives and processes the events.

#### Scenario: Delay between clipboard write and Cmd+V simulation
- **WHEN** the clipboard fallback places transformed text on the clipboard
- **THEN** the service SHALL wait at least 50ms before simulating Cmd+V
- **AND** the service SHALL wait at least 50ms between key-down and key-up events

#### Scenario: Delay after Cmd+V for paste to process
- **WHEN** Cmd+V is simulated
- **THEN** the service SHALL wait at least 100ms for the paste to be processed before proceeding

### Requirement: Clipboard fallback detects paste failure
The clipboard fallback SHALL attempt to detect whether the paste actually succeeded by verifying the focused element's content changed. If detection is not possible, the fallback SHALL still return `.fallbackClipboard` but log the uncertainty.

#### Scenario: Clipboard fallback with verification
- **WHEN** the clipboard fallback simulates Cmd+V
- **AND** the focused element supports reading selected text via AX
- **THEN** the service SHALL verify the pasted text is present
- **AND** return `.fallbackClipboard` on success or fall through to `.copiedToClipboard` on failure

#### Scenario: Clipboard fallback without verification
- **WHEN** the clipboard fallback simulates Cmd+V
- **AND** the focused element does NOT support reading text via AX
- **THEN** the service SHALL return `.fallbackClipboard` (best effort)

### Requirement: Toast overlay must not steal keyboard focus during replacement
The toast overlay panel SHALL NOT become the key window or first responder at any point during the transformation pipeline. Toast display during the processing state SHALL be deferred until after the replacement step completes, OR the panel SHALL be configured to never accept key focus.

#### Scenario: Toast display does not interfere with text replacement
- **WHEN** a transformation is in progress
- **AND** the toast overlay shows a processing or status update
- **THEN** the user's frontmost application SHALL remain the keyboard focus target
- **AND** `simulateCmdV()` CGEvents SHALL be received by the user's application, not by InDraft

#### Scenario: Panel refuses key window status
- **WHEN** the toast overlay panel is displayed
- **THEN** the panel SHALL return `false` for `canBecomeKey`
- **AND** the panel SHALL return `false` for `canBecomeMain`

### Requirement: Replace function returns accurate result status
The `replaceSelectedText(with:)` function SHALL return a result that accurately reflects what happened. The `.fallbackClipboard` result SHALL only be returned when there is reasonable confidence the paste succeeded.

#### Scenario: Clipboard fallback function can actually fail
- **WHEN** `replaceViaClipboard` is called
- **AND** the paste simulation does not result in text being inserted
- **THEN** the function SHALL throw or return a failure indicator
- **AND** the service SHALL fall through to the `.copiedToClipboard` last resort

#### Scenario: Last resort correctly copies to clipboard
- **WHEN** both AX and clipboard replacement fail
- **THEN** the transformed text SHALL be placed on the clipboard
- **AND** the result SHALL be `.copiedToClipboard`
- **AND** the user SHALL see "Result copied to clipboard — paste manually" toast
