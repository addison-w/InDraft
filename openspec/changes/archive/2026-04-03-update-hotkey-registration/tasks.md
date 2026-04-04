## 1. Fix Carbon ID Reset Bug

- [x] 1.1 Write test: `deregisterAll()` resets internal state so re-registration succeeds for N hotkeys across multiple cycles
- [x] 1.2 Add `nextCarbonID = 1` to `LiveHotkeyService.deregisterAll()` in `InDraft/Services/HotkeyService.swift`
- [x] 1.3 Write test: Register 3+ hotkeys simultaneously and verify all succeed

## 2. Fix Default Action Modifier Encoding

- [x] 2.1 Write test: Verify `Constants.DefaultActions` modifier values match `NSEvent.ModifierFlags` encoding (not Carbon flags)
- [x] 2.2 Update `Constants.DefaultActions` in `InDraft/Utilities/Constants.swift` to use `NSEvent.ModifierFlags` raw values for `modifiers` instead of Carbon `controlKey | optionKey`
- [x] 2.3 Write test: Round-trip `nsToCarbonModifiers()` on default action modifiers produces correct Carbon mask

## 3. Verify End-to-End

- [x] 3.1 Build the project and verify no compilation errors
- [x] 3.2 Run all unit tests and verify they pass
