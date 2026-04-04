## Context

`LiveHotkeyService` manages global hotkey registration via the Carbon Event Manager API. It uses a `nextCarbonID` counter to assign unique IDs to each `EventHotKeyID`. When `deregisterAll()` is called (e.g., during `AppCoordinator.registerAllHotkeys()`), all hotkeys are unregistered from Carbon but `nextCarbonID` is never reset — it continues incrementing indefinitely.

The default actions in `Constants.DefaultActions` define hotkeys using Carbon modifier flags (`controlKey | optionKey`), but the Action model stores `hotkeyModifiers` as `UInt32`. The `register()` method calls `nsToCarbonModifiers()` on the stored value, meaning the stored value is expected to be `NSEvent.ModifierFlags` raw values, not Carbon flags. This encoding mismatch needs verification.

### Current hotkey registration flow

1. `AppCoordinator.registerAllHotkeys()` calls `hotkeyService.deregisterAll()`
2. Fetches all enabled actions with hotkeys from SwiftData
3. Calls `hotkeyService.register()` for each, which assigns `nextCarbonID` and calls `RegisterEventHotKey()`
4. `nextCarbonID` increments but never resets

### Interfaces affected

- `LiveHotkeyService` (concrete implementation) — internal state fix
- `HotkeyServiceProtocol` — no changes needed (protocol is correct)
- `MockHotkeyService` — no changes needed (doesn't use Carbon IDs)

## Goals / Non-Goals

**Goals:**
- Reset `nextCarbonID` in `deregisterAll()` so Carbon IDs are reused cleanly
- Verify default action modifier encoding is consistent (Carbon vs NSEvent flags)
- Ensure no artificial limit on the number of simultaneous hotkey registrations

**Non-Goals:**
- Changing the `HotkeyServiceProtocol` interface
- Refactoring the Carbon Event Handler installation
- Adding new protocol methods or mock capabilities
- Changing how `AppCoordinator` calls registration

## Decisions

### Decision 1: Reset `nextCarbonID` in `deregisterAll()`

**Choice**: Add `nextCarbonID = 1` at the end of `deregisterAll()`.

**Rationale**: After all hotkeys are unregistered from Carbon, the IDs are free to reuse. Resetting ensures clean state and prevents unbounded ID growth. The alternative — letting it grow — is technically safe for UInt32 range but is sloppy state management and makes debugging harder.

**Alternative considered**: Reset in `register()` when `registrations.isEmpty`. Rejected because it couples reset logic to a different method and is less obvious.

### Decision 2: Verify modifier flag encoding in Constants.swift

**Choice**: Check whether `Constants.DefaultActions` uses Carbon flags (`controlKey | optionKey`) or NSEvent flags. If Carbon, convert to NSEvent flags since that's what `register()` expects via `nsToCarbonModifiers()`.

**Rationale**: `register()` calls `nsToCarbonModifiers()` which treats the input as `NSEvent.ModifierFlags.rawValue`. If the stored value is already Carbon flags, the conversion double-encodes them, producing incorrect modifier masks.

### Decision 3: No explicit registration count limit

**Choice**: Verify there is no hardcoded limit in the registration logic. The `registrations` dictionary is unbounded by design — Carbon Event Manager supports many hotkeys per application.

**Rationale**: The user reports only 2 hotkeys can be registered. This is likely caused by the modifier encoding bug (Decision 2) rather than an explicit count limit, since the code uses an open-ended dictionary.

## Testability

- **Unit test**: `LiveHotkeyService` — verify `deregisterAll()` resets internal state by registering N hotkeys, deregistering all, and re-registering N hotkeys successfully
- **Unit test**: Verify `nsToCarbonModifiers()` correctly converts NSEvent modifier flags
- **Unit test**: Verify default action constants use the correct modifier encoding
- **Existing mock**: `MockHotkeyService` needs no changes — it doesn't use Carbon IDs

## Risks / Trade-offs

- **[Low] Carbon ID reuse after partial deregister**: `deregister(actionID:)` (single deregister) does not reset `nextCarbonID`. This is correct — reusing IDs while other hotkeys are still registered could cause collisions. Only `deregisterAll()` resets.
- **[Low] Modifier encoding fix may change existing user hotkeys**: If users have saved actions with incorrect modifier encoding, fixing the encoding could make their saved hotkeys stop working. Mitigation: The fix is to the default constants only; existing saved actions use whatever the recorder wrote, which should already be correct NSEvent flags.
