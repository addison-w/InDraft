## Why

The hotkey registration system has a bug where `nextCarbonID` in `LiveHotkeyService.deregisterAll()` is never reset, causing Carbon Event IDs to monotonically increase across registration cycles. While this doesn't immediately break registration, it means stale IDs accumulate and can eventually cause registration failures. Additionally, the default action hotkeys (Control+Option+1/2/3) are defined in `Constants.swift` using Carbon modifier flags (`controlKey | optionKey`) but stored in the Action model as `NSEvent.ModifierFlags` raw values — this mismatch needs verification and cleanup.

## What Changes

- Fix `LiveHotkeyService.deregisterAll()` to reset `nextCarbonID` so Carbon Event IDs are reused after full deregistration cycles
- Verify and correct the default action hotkey modifier encoding in `Constants.swift` to ensure it matches what `HotkeyService.register()` expects (NSEvent modifier flags vs Carbon modifier flags)
- Ensure unlimited hotkey registrations are supported — remove any artificial cap on the number of simultaneous hotkey registrations

## Non-goals

- Changing the hotkey recorder UI
- Adding new default actions beyond the existing 3
- Changing the hotkey conflict detection logic
- Modifying window management or activation policy

## Capabilities

### New Capabilities

_None — this is a bugfix to existing functionality._

### Modified Capabilities

- `hotkey-system`: Fix Carbon ID lifecycle bug in deregisterAll() and ensure unlimited simultaneous registrations

## Impact

- **Code**: `InDraft/Services/HotkeyService.swift` (primary fix), `InDraft/Utilities/Constants.swift` (verify modifier encoding)
- **Services affected**: HotkeyService (LiveHotkeyService implementation)
- **Models affected**: None (Action model hotkey fields unchanged)
- **Risk**: Low — isolated fix to internal state management in a single service
- **Complexity**: S
