import XCTest
import Carbon.HIToolbox
@testable import InDraft

final class HotkeyServiceTests: XCTestCase {
    var sut: MockHotkeyService!

    override func setUp() {
        super.setUp()
        sut = MockHotkeyService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Register & Deregister

    func testRegisterAndIsRegistered() throws {
        let actionID = UUID()
        try sut.register(keyCode: 18, modifiers: 0, actionID: actionID)
        XCTAssertTrue(sut.isRegistered(actionID: actionID))
    }

    func testDeregisterRemovesRegistration() throws {
        let actionID = UUID()
        try sut.register(keyCode: 18, modifiers: 0, actionID: actionID)
        sut.deregister(actionID: actionID)
        XCTAssertFalse(sut.isRegistered(actionID: actionID))
    }

    func testDeregisterNonExistentDoesNotThrow() {
        sut.deregister(actionID: UUID())
    }

    func testDeregisterAllClearsEverything() throws {
        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        try sut.register(keyCode: 18, modifiers: 0, actionID: id1)
        try sut.register(keyCode: 19, modifiers: 0, actionID: id2)
        try sut.register(keyCode: 20, modifiers: 0, actionID: id3)

        sut.deregisterAll()

        XCTAssertFalse(sut.isRegistered(actionID: id1))
        XCTAssertFalse(sut.isRegistered(actionID: id2))
        XCTAssertFalse(sut.isRegistered(actionID: id3))
    }

    // MARK: - Already Registered

    func testRegisterSameActionTwiceThrows() throws {
        let actionID = UUID()
        try sut.register(keyCode: 18, modifiers: 0, actionID: actionID)

        XCTAssertThrowsError(try sut.register(keyCode: 19, modifiers: 0, actionID: actionID)) { error in
            XCTAssertEqual(error as? HotkeyError, .alreadyRegistered)
        }
    }

    // MARK: - Conflict Detection

    func testConflictDetectedForSameKeyCombo() throws {
        let id1 = UUID()
        let id2 = UUID()
        let keyCode: UInt32 = 18
        let modifiers: UInt32 = UInt32(NSEvent.ModifierFlags.control.rawValue | NSEvent.ModifierFlags.option.rawValue)

        try sut.register(keyCode: keyCode, modifiers: modifiers, actionID: id1)

        let conflicting = sut.hasConflict(keyCode: keyCode, modifiers: modifiers, excludingActionID: nil)
        XCTAssertEqual(conflicting, id1)

        // id2 is not registered, so excluding it should still find id1
        let conflicting2 = sut.hasConflict(keyCode: keyCode, modifiers: modifiers, excludingActionID: id2)
        XCTAssertEqual(conflicting2, id1)
    }

    func testNoConflictWhenExcludingOwnActionID() throws {
        let actionID = UUID()
        let keyCode: UInt32 = 18
        let modifiers: UInt32 = UInt32(NSEvent.ModifierFlags.control.rawValue)

        try sut.register(keyCode: keyCode, modifiers: modifiers, actionID: actionID)

        let conflicting = sut.hasConflict(keyCode: keyCode, modifiers: modifiers, excludingActionID: actionID)
        XCTAssertNil(conflicting)
    }

    func testNoConflictForDifferentKeyCombos() throws {
        let id1 = UUID()
        try sut.register(keyCode: 18, modifiers: UInt32(NSEvent.ModifierFlags.control.rawValue), actionID: id1)

        let conflicting = sut.hasConflict(keyCode: 19, modifiers: UInt32(NSEvent.ModifierFlags.control.rawValue), excludingActionID: nil)
        XCTAssertNil(conflicting)
    }

    func testNoConflictForDifferentModifiers() throws {
        let id1 = UUID()
        try sut.register(keyCode: 18, modifiers: UInt32(NSEvent.ModifierFlags.control.rawValue), actionID: id1)

        let conflicting = sut.hasConflict(keyCode: 18, modifiers: UInt32(NSEvent.ModifierFlags.option.rawValue), excludingActionID: nil)
        XCTAssertNil(conflicting)
    }

    // MARK: - Callback

    func testOnHotkeyPressedCallbackFires() throws {
        let actionID = UUID()
        try sut.register(keyCode: 18, modifiers: 0, actionID: actionID)

        var receivedID: UUID?
        sut.onHotkeyPressed = { id in
            receivedID = id
        }

        sut.simulateHotkeyPress(actionID: actionID)
        XCTAssertEqual(receivedID, actionID)
    }

    func testSimulateHotkeyPressDoesNothingForUnregistered() {
        var callbackCalled = false
        sut.onHotkeyPressed = { _ in
            callbackCalled = true
        }

        sut.simulateHotkeyPress(actionID: UUID())
        XCTAssertFalse(callbackCalled)
    }

    // MARK: - DeregisterAll Reset & Re-registration

    func testDeregisterAllAllowsReRegistration() throws {
        let id1 = UUID(), id2 = UUID(), id3 = UUID()
        try sut.register(keyCode: 18, modifiers: 0, actionID: id1)
        try sut.register(keyCode: 19, modifiers: 0, actionID: id2)
        try sut.register(keyCode: 20, modifiers: 0, actionID: id3)

        sut.deregisterAll()

        // Re-register with new action IDs — should succeed
        let id4 = UUID(), id5 = UUID(), id6 = UUID()
        try sut.register(keyCode: 18, modifiers: 0, actionID: id4)
        try sut.register(keyCode: 19, modifiers: 0, actionID: id5)
        try sut.register(keyCode: 20, modifiers: 0, actionID: id6)

        XCTAssertTrue(sut.isRegistered(actionID: id4))
        XCTAssertTrue(sut.isRegistered(actionID: id5))
        XCTAssertTrue(sut.isRegistered(actionID: id6))
    }

    func testMultipleDeregisterRegisterCycles() throws {
        for _ in 0..<5 {
            let ids = (0..<3).map { _ in UUID() }
            for (i, id) in ids.enumerated() {
                try sut.register(keyCode: UInt32(18 + i), modifiers: 0, actionID: id)
            }
            for id in ids {
                XCTAssertTrue(sut.isRegistered(actionID: id))
            }
            sut.deregisterAll()
        }
    }

    func testRegisterThreeOrMoreHotkeysSimultaneously() throws {
        let modifiers = UInt32(NSEvent.ModifierFlags([.control, .option]).rawValue)
        let ids = (0..<5).map { _ in UUID() }

        for (i, id) in ids.enumerated() {
            try sut.register(keyCode: UInt32(18 + i), modifiers: modifiers, actionID: id)
        }

        for id in ids {
            XCTAssertTrue(sut.isRegistered(actionID: id))
        }
    }

    // MARK: - Live Service Carbon ID Reset

    func testLiveDeregisterAllResetsCarbonIDs() throws {
        let live = LiveHotkeyService()
        let id1 = UUID(), id2 = UUID()
        let modifiers = UInt32(NSEvent.ModifierFlags([.control, .option]).rawValue)

        try live.register(keyCode: 18, modifiers: modifiers, actionID: id1)
        try live.register(keyCode: 19, modifiers: modifiers, actionID: id2)
        live.deregisterAll()

        // After deregisterAll, re-registration should succeed
        let id3 = UUID(), id4 = UUID(), id5 = UUID()
        try live.register(keyCode: 18, modifiers: modifiers, actionID: id3)
        try live.register(keyCode: 19, modifiers: modifiers, actionID: id4)
        try live.register(keyCode: 20, modifiers: modifiers, actionID: id5)

        XCTAssertTrue(live.isRegistered(actionID: id3))
        XCTAssertTrue(live.isRegistered(actionID: id4))
        XCTAssertTrue(live.isRegistered(actionID: id5))

        live.deregisterAll()
    }

    // MARK: - Modifier Conversion

    func testNSToCarbonModifiersConvertsCorrectly() {
        let nsModifiers = UInt32(NSEvent.ModifierFlags([.control, .option]).rawValue)
        let carbon = LiveHotkeyService.nsToCarbonModifiers(nsModifiers)

        XCTAssertEqual(carbon & UInt32(controlKey), UInt32(controlKey))
        XCTAssertEqual(carbon & UInt32(optionKey), UInt32(optionKey))
        XCTAssertEqual(carbon & UInt32(cmdKey), 0)
        XCTAssertEqual(carbon & UInt32(shiftKey), 0)
    }

    func testNSToCarbonModifiersRejectsCarbonInput() {
        // Carbon flags (controlKey | optionKey) should NOT produce valid output
        // when passed through nsToCarbonModifiers (which expects NSEvent flags)
        let carbonFlags = UInt32(controlKey | optionKey)
        let result = LiveHotkeyService.nsToCarbonModifiers(carbonFlags)

        // Carbon controlKey=0x1000, optionKey=0x0800 — these bits don't overlap
        // with NSEvent .control (bit 18) or .option (bit 19), so result should be 0
        XCTAssertEqual(result, 0, "Carbon flags passed to nsToCarbonModifiers should produce empty result")
    }

    // MARK: - Protocol Conformance

    func testMockConformsToProtocol() {
        let service: HotkeyServiceProtocol = MockHotkeyService()
        XCTAssertNotNil(service)
    }

    func testLiveConformsToProtocol() {
        let service: HotkeyServiceProtocol = LiveHotkeyService()
        XCTAssertNotNil(service)
    }
}
