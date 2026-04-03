import XCTest
@testable import InDraft

@MainActor
final class AppStateTests: XCTestCase {

    func testInitialStateIsIdle() {
        let state = AppState()
        XCTAssertEqual(state.status, .idle)
    }

    func testSetProcessing() {
        let state = AppState()
        state.setProcessing()
        XCTAssertEqual(state.status, .processing)
    }

    func testSetSuccess() {
        let state = AppState()
        state.setSuccess()
        XCTAssertEqual(state.status, .success)
    }

    func testSetError() {
        let state = AppState()
        state.setError("Something went wrong")
        XCTAssertEqual(state.status, .error(message: "Something went wrong"))
    }

    func testSetPermissionRequired() {
        let state = AppState()
        state.setPermissionRequired()
        XCTAssertEqual(state.status, .permissionRequired)
    }

    func testSetIdle() {
        let state = AppState()
        state.setProcessing()
        state.setIdle()
        XCTAssertEqual(state.status, .idle)
    }

    func testProcessingToSuccess() {
        let state = AppState()
        state.setProcessing()
        XCTAssertEqual(state.status, .processing)
        state.setSuccess()
        XCTAssertEqual(state.status, .success)
    }

    func testProcessingToError() {
        let state = AppState()
        state.setProcessing()
        XCTAssertEqual(state.status, .processing)
        state.setError("API failed")
        XCTAssertEqual(state.status, .error(message: "API failed"))
    }

    func testPermissionRequiredIsPersistent() {
        let state = AppState()
        state.setPermissionRequired()
        // permissionRequired should not auto-dismiss
        XCTAssertEqual(state.status, .permissionRequired)
    }

    func testSuccessAutoDismiss() async {
        let state = AppState()
        state.setSuccess()
        XCTAssertEqual(state.status, .success)

        // Wait slightly over 3 seconds for auto-dismiss
        try? await Task.sleep(for: .seconds(3.5))
        XCTAssertEqual(state.status, .idle)
    }

    func testErrorAutoDismiss() async {
        let state = AppState()
        state.setError("fail")
        XCTAssertEqual(state.status, .error(message: "fail"))

        // Wait slightly over 10 seconds for auto-dismiss
        try? await Task.sleep(for: .seconds(10.5))
        XCTAssertEqual(state.status, .idle)
    }

    func testRapidStateChangesCancelsPreviousDismiss() async {
        let state = AppState()
        state.setSuccess() // Would dismiss after 3s
        state.setProcessing() // Should cancel the 3s dismiss
        XCTAssertEqual(state.status, .processing)

        try? await Task.sleep(for: .seconds(4))
        // Should still be processing, not idle
        XCTAssertEqual(state.status, .processing)
    }
}
