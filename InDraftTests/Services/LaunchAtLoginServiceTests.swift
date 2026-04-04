import XCTest
@testable import InDraft

final class LaunchAtLoginServiceTests: XCTestCase {
    var sut: MockLaunchAtLoginService!

    override func setUp() {
        super.setUp()
        sut = MockLaunchAtLoginService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialStateIsDisabled() {
        XCTAssertFalse(sut.isEnabled)
    }

    // MARK: - Enable

    func testSetEnabledTrueRegistersLoginItem() throws {
        try sut.setEnabled(true)
        XCTAssertTrue(sut.isEnabled)
    }

    func testSetEnabledTrueIncrementsCallCount() throws {
        try sut.setEnabled(true)
        XCTAssertEqual(sut.setEnabledCallCount, 1)
        XCTAssertEqual(sut.lastSetEnabledValue, true)
    }

    func testSetEnabledTrueWhenAlreadyEnabledRemainsEnabled() throws {
        try sut.setEnabled(true)
        try sut.setEnabled(true)
        XCTAssertTrue(sut.isEnabled)
        XCTAssertEqual(sut.setEnabledCallCount, 2)
    }

    // MARK: - Disable

    func testSetEnabledFalseUnregistersLoginItem() throws {
        try sut.setEnabled(true)
        try sut.setEnabled(false)
        XCTAssertFalse(sut.isEnabled)
    }

    func testSetEnabledFalseTracksCallCorrectly() throws {
        try sut.setEnabled(true)
        try sut.setEnabled(false)
        XCTAssertEqual(sut.setEnabledCallCount, 2)
        XCTAssertEqual(sut.lastSetEnabledValue, false)
    }

    func testSetEnabledFalseWhenAlreadyDisabledRemainsDisabled() throws {
        try sut.setEnabled(false)
        XCTAssertFalse(sut.isEnabled)
        XCTAssertEqual(sut.setEnabledCallCount, 1)
    }

    // MARK: - Error Handling

    func testEnableThrowsOnRegistrationFailure() {
        sut.shouldThrowOnEnable = true
        XCTAssertThrowsError(try sut.setEnabled(true)) { error in
            guard let launchError = error as? LaunchAtLoginError else {
                XCTFail("Expected LaunchAtLoginError")
                return
            }
            if case .registrationFailed(let message) = launchError {
                XCTAssertEqual(message, "Mock registration failed")
            } else {
                XCTFail("Expected registrationFailed error")
            }
        }
        // Should remain disabled after failed registration
        XCTAssertFalse(sut.isEnabled)
    }

    func testDisableThrowsOnUnregistrationFailure() throws {
        try sut.setEnabled(true)
        sut.shouldThrowOnDisable = true
        XCTAssertThrowsError(try sut.setEnabled(false)) { error in
            guard let launchError = error as? LaunchAtLoginError else {
                XCTFail("Expected LaunchAtLoginError")
                return
            }
            if case .unregistrationFailed(let message) = launchError {
                XCTAssertEqual(message, "Mock unregistration failed")
            } else {
                XCTFail("Expected unregistrationFailed error")
            }
        }
        // Should remain enabled after failed unregistration
        XCTAssertTrue(sut.isEnabled)
    }

    func testEnableFailureDoesNotIncrementState() {
        sut.shouldThrowOnEnable = true
        _ = try? sut.setEnabled(true)
        XCTAssertEqual(sut.setEnabledCallCount, 1)
        XCTAssertFalse(sut.isEnabled)
    }

    // MARK: - Toggle Cycle

    func testFullToggleCycle() throws {
        // Start disabled
        XCTAssertFalse(sut.isEnabled)

        // Enable
        try sut.setEnabled(true)
        XCTAssertTrue(sut.isEnabled)

        // Disable
        try sut.setEnabled(false)
        XCTAssertFalse(sut.isEnabled)

        // Re-enable
        try sut.setEnabled(true)
        XCTAssertTrue(sut.isEnabled)

        XCTAssertEqual(sut.setEnabledCallCount, 3)
    }

    // MARK: - Error Equatability

    func testErrorEquatability() {
        let error1 = LaunchAtLoginError.registrationFailed("test")
        let error2 = LaunchAtLoginError.registrationFailed("test")
        let error3 = LaunchAtLoginError.unregistrationFailed("test")

        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }
}
