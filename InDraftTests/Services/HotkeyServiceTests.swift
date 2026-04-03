import XCTest
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
