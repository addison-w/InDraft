import Cocoa
import Carbon

// MARK: - Protocol

protocol HotkeyServiceProtocol: AnyObject {
    /// Register a global hotkey for the given action ID.
    func register(keyCode: UInt32, modifiers: UInt32, actionID: UUID) throws
    /// Deregister the hotkey for the given action ID.
    func deregister(actionID: UUID)
    /// Deregister all hotkeys.
    func deregisterAll()
    /// Check if a hotkey is registered for the given action ID.
    func isRegistered(actionID: UUID) -> Bool
    /// Check if a hotkey combination conflicts with an existing registration.
    /// Returns the conflicting action ID, or nil if no conflict.
    func hasConflict(keyCode: UInt32, modifiers: UInt32, excludingActionID: UUID?) -> UUID?
    /// Callback invoked when a registered hotkey is pressed.
    var onHotkeyPressed: ((UUID) -> Void)? { get set }
}

// MARK: - Errors

enum HotkeyError: Error, Equatable {
    case registrationFailed(keyCode: UInt32, modifiers: UInt32)
    case alreadyRegistered
}

// MARK: - Registration Info

private struct HotkeyRegistration {
    let keyCode: UInt32
    let modifiers: UInt32
    let hotKeyRef: EventHotKeyRef?
    let carbonID: UInt32
}

// MARK: - Live Implementation

final class LiveHotkeyService: HotkeyServiceProtocol {
    var onHotkeyPressed: ((UUID) -> Void)?

    private var registrations: [UUID: HotkeyRegistration] = [:]
    private var idToAction: [UInt32: UUID] = [:]
    private var nextCarbonID: UInt32 = 1
    private var eventHandlerRef: EventHandlerRef?

    private static let hotKeySignature: FourCharCode = {
        let chars: [UInt8] = [
            UInt8(ascii: "I"),
            UInt8(ascii: "n"),
            UInt8(ascii: "D"),
            UInt8(ascii: "r")
        ]
        return FourCharCode(chars[0]) << 24
             | FourCharCode(chars[1]) << 16
             | FourCharCode(chars[2]) << 8
             | FourCharCode(chars[3])
    }()

    init() {
        installEventHandler()
    }

    deinit {
        deregisterAll()
        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
        }
    }

    // MARK: - Protocol Methods

    func register(keyCode: UInt32, modifiers: UInt32, actionID: UUID) throws {
        // Check if this action already has a hotkey registered
        if registrations[actionID] != nil {
            throw HotkeyError.alreadyRegistered
        }

        let carbonID = nextCarbonID
        nextCarbonID += 1

        let carbonModifiers = Self.nsToCarbonModifiers(modifiers)

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = Self.hotKeySignature
        hotKeyID.id = carbonID

        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(
            keyCode,
            carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr, hotKeyRef != nil else {
            throw HotkeyError.registrationFailed(keyCode: keyCode, modifiers: modifiers)
        }

        let registration = HotkeyRegistration(
            keyCode: keyCode,
            modifiers: modifiers,
            hotKeyRef: hotKeyRef,
            carbonID: carbonID
        )
        registrations[actionID] = registration
        idToAction[carbonID] = actionID
    }

    func deregister(actionID: UUID) {
        guard let registration = registrations.removeValue(forKey: actionID) else { return }
        idToAction.removeValue(forKey: registration.carbonID)
        if let ref = registration.hotKeyRef {
            UnregisterEventHotKey(ref)
        }
    }

    func deregisterAll() {
        for (_, registration) in registrations {
            if let ref = registration.hotKeyRef {
                UnregisterEventHotKey(ref)
            }
        }
        registrations.removeAll()
        idToAction.removeAll()
        nextCarbonID = 1
    }

    func isRegistered(actionID: UUID) -> Bool {
        registrations[actionID] != nil
    }

    func hasConflict(keyCode: UInt32, modifiers: UInt32, excludingActionID: UUID?) -> UUID? {
        for (actionID, registration) in registrations {
            if actionID == excludingActionID { continue }
            if registration.keyCode == keyCode && registration.modifiers == modifiers {
                return actionID
            }
        }
        return nil
    }

    // MARK: - Carbon Event Handler

    private func installEventHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData -> OSStatus in
                guard let userData = userData else { return OSStatus(eventNotHandledErr) }
                let service = Unmanaged<LiveHotkeyService>.fromOpaque(userData).takeUnretainedValue()
                return service.handleHotKeyEvent(event)
            },
            1,
            &eventType,
            selfPtr,
            &eventHandlerRef
        )
    }

    private func handleHotKeyEvent(_ event: EventRef?) -> OSStatus {
        guard let event = event else { return OSStatus(eventNotHandledErr) }

        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )

        guard status == noErr else { return status }

        if let actionID = idToAction[hotKeyID.id] {
            onHotkeyPressed?(actionID)
        }

        return noErr
    }

    // MARK: - Modifier Conversion

    /// Convert NSEvent modifier flags (stored as UInt32) to Carbon modifier mask.
    static func nsToCarbonModifiers(_ nsModifiers: UInt32) -> UInt32 {
        var carbon: UInt32 = 0
        let flags = NSEvent.ModifierFlags(rawValue: UInt(nsModifiers))
        if flags.contains(.control) { carbon |= UInt32(controlKey) }
        if flags.contains(.option)  { carbon |= UInt32(optionKey) }
        if flags.contains(.shift)   { carbon |= UInt32(shiftKey) }
        if flags.contains(.command) { carbon |= UInt32(cmdKey) }
        return carbon
    }

    /// Convert Carbon modifier mask to NSEvent modifier flags stored as UInt32.
    static func carbonToNSModifiers(_ carbonModifiers: UInt32) -> UInt32 {
        var flags: NSEvent.ModifierFlags = []
        if carbonModifiers & UInt32(controlKey) != 0 { flags.insert(.control) }
        if carbonModifiers & UInt32(optionKey) != 0  { flags.insert(.option) }
        if carbonModifiers & UInt32(shiftKey) != 0   { flags.insert(.shift) }
        if carbonModifiers & UInt32(cmdKey) != 0     { flags.insert(.command) }
        return UInt32(flags.rawValue)
    }
}

// MARK: - Mock Implementation

final class MockHotkeyService: HotkeyServiceProtocol {
    var onHotkeyPressed: ((UUID) -> Void)?

    private struct MockRegistration {
        let keyCode: UInt32
        let modifiers: UInt32
    }

    private var registrations: [UUID: MockRegistration] = [:]

    func register(keyCode: UInt32, modifiers: UInt32, actionID: UUID) throws {
        if registrations[actionID] != nil {
            throw HotkeyError.alreadyRegistered
        }
        registrations[actionID] = MockRegistration(keyCode: keyCode, modifiers: modifiers)
    }

    func deregister(actionID: UUID) {
        registrations.removeValue(forKey: actionID)
    }

    func deregisterAll() {
        registrations.removeAll()
    }

    func isRegistered(actionID: UUID) -> Bool {
        registrations[actionID] != nil
    }

    func hasConflict(keyCode: UInt32, modifiers: UInt32, excludingActionID: UUID?) -> UUID? {
        for (actionID, reg) in registrations {
            if actionID == excludingActionID { continue }
            if reg.keyCode == keyCode && reg.modifiers == modifiers {
                return actionID
            }
        }
        return nil
    }

    /// Simulate a hotkey press for testing purposes.
    func simulateHotkeyPress(actionID: UUID) {
        guard registrations[actionID] != nil else { return }
        onHotkeyPressed?(actionID)
    }
}
