import XCTest
@testable import InDraft

@MainActor
final class ToastManagerTests: XCTestCase {

    func testInitialStateIsNil() {
        let manager = ToastManager()
        XCTAssertNil(manager.currentToast)
    }

    func testShowSetsCurrentToast() {
        let manager = ToastManager()
        manager.show(.success("Text replaced"))
        XCTAssertNotNil(manager.currentToast)
        XCTAssertEqual(manager.currentToast?.message, "Text replaced")
    }

    func testShowErrorSetsCurrentToast() {
        let manager = ToastManager()
        manager.show(.error("API key invalid"))
        XCTAssertNotNil(manager.currentToast)
        XCTAssertEqual(manager.currentToast?.message, "API key invalid")
    }

    func testShowInfoSetsCurrentToast() {
        let manager = ToastManager()
        manager.show(.info("No text selected"))
        XCTAssertNotNil(manager.currentToast)
        XCTAssertEqual(manager.currentToast?.message, "No text selected")
    }

    func testDismissClearsToast() {
        let manager = ToastManager()
        manager.show(.success("done"))
        XCTAssertNotNil(manager.currentToast)
        manager.dismiss()
        XCTAssertNil(manager.currentToast)
    }

    func testRapidReplacementShowsLatestToast() {
        let manager = ToastManager()
        manager.show(.success("first"))
        manager.show(.error("second"))
        XCTAssertEqual(manager.currentToast?.message, "second")
    }

    func testSuccessAutoDismiss() async {
        let manager = ToastManager()
        manager.show(.success("done"))
        XCTAssertNotNil(manager.currentToast)

        // Success dismisses after Constants.Defaults.toastSuccessDismiss (2s)
        try? await Task.sleep(for: .seconds(2.5))
        XCTAssertNil(manager.currentToast)
    }

    func testErrorAutoDismiss() async {
        let manager = ToastManager()
        manager.show(.error("fail"))
        XCTAssertNotNil(manager.currentToast)

        // Error dismisses after Constants.Defaults.toastErrorDismiss (5s)
        try? await Task.sleep(for: .seconds(5.5))
        XCTAssertNil(manager.currentToast)
    }

    func testRapidReplacementCancelsPreviousTimer() async {
        let manager = ToastManager()
        manager.show(.success("first")) // Would dismiss after 2s
        manager.show(.error("second"))  // Should cancel the 2s timer

        // Wait past the success dismiss time
        try? await Task.sleep(for: .seconds(2.5))
        // Should still show "second" (error has 5s timer)
        XCTAssertNotNil(manager.currentToast)
        XCTAssertEqual(manager.currentToast?.message, "second")
    }
}
