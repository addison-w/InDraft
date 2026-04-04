import XCTest
@testable import InDraft

final class TextCaptureServiceTests: XCTestCase {
    var sut: MockTextCaptureService!

    override func setUp() {
        super.setUp()
        sut = MockTextCaptureService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Successful Capture

    func testCaptureReturnsExpectedText() async throws {
        sut.resultToReturn = .success("Hello, world!")

        let result = try await sut.captureSelectedText()
        XCTAssertEqual(result, "Hello, world!")
    }

    // MARK: - Empty Selection

    func testCaptureWithEmptySelectionThrowsNoTextSelected() async {
        sut.resultToReturn = .success("")

        do {
            _ = try await sut.captureSelectedText()
            XCTFail("Expected noTextSelected error")
        } catch {
            XCTAssertEqual(error as? CaptureError, .noTextSelected)
        }
    }

    // MARK: - Fallback Behavior

    func testCaptureFallbackClipboardError() async {
        sut.resultToReturn = .failure(.captureFailedClipboard)

        do {
            _ = try await sut.captureSelectedText()
            XCTFail("Expected captureFailedClipboard error")
        } catch {
            XCTAssertEqual(error as? CaptureError, .captureFailedClipboard)
        }
    }

    func testCaptureFallbackAXError() async {
        sut.resultToReturn = .failure(.captureFailedAX)

        do {
            _ = try await sut.captureSelectedText()
            XCTFail("Expected captureFailedAX error")
        } catch {
            XCTAssertEqual(error as? CaptureError, .captureFailedAX)
        }
    }

    // MARK: - Both Fail

    func testCaptureBothFailedScenario() async {
        sut.resultToReturn = .failure(.bothFailed)

        do {
            _ = try await sut.captureSelectedText()
            XCTFail("Expected bothFailed error")
        } catch {
            XCTAssertEqual(error as? CaptureError, .bothFailed)
        }
    }

    // MARK: - Protocol Conformance

    func testMockConformsToProtocol() {
        let service: TextCaptureServiceProtocol = MockTextCaptureService()
        XCTAssertNotNil(service)
    }

    func testLiveConformsToProtocol() {
        let service: TextCaptureServiceProtocol = LiveTextCaptureService()
        XCTAssertNotNil(service)
    }
}
