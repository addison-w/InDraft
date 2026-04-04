import XCTest
@testable import InDraft

final class TextReplaceServiceTests: XCTestCase {
    var sut: MockTextReplaceService!

    override func setUp() {
        super.setUp()
        sut = MockTextReplaceService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Replaced via AX

    func testReplaceReturnsReplaced() async throws {
        sut.resultToReturn = .replaced

        let result = try await sut.replaceSelectedText(with: "new text")
        XCTAssertEqual(result, .replaced)
    }

    // MARK: - Fallback Clipboard

    func testReplaceFallbackClipboard() async throws {
        sut.resultToReturn = .fallbackClipboard

        let result = try await sut.replaceSelectedText(with: "new text")
        XCTAssertEqual(result, .fallbackClipboard)
    }

    // MARK: - Total Failure: Copied to Clipboard

    func testReplaceCopiedToClipboard() async throws {
        sut.resultToReturn = .copiedToClipboard

        let result = try await sut.replaceSelectedText(with: "new text")
        XCTAssertEqual(result, .copiedToClipboard)
    }

    // MARK: - Protocol Conformance

    func testMockConformsToProtocol() {
        let service: TextReplaceServiceProtocol = MockTextReplaceService()
        XCTAssertNotNil(service)
    }

    func testLiveConformsToProtocol() {
        let service: TextReplaceServiceProtocol = LiveTextReplaceService()
        XCTAssertNotNil(service)
    }

    // MARK: - ReplaceResult Equality

    func testReplaceResultEquality() {
        XCTAssertEqual(ReplaceResult.replaced, ReplaceResult.replaced)
        XCTAssertEqual(ReplaceResult.fallbackClipboard, ReplaceResult.fallbackClipboard)
        XCTAssertEqual(ReplaceResult.copiedToClipboard, ReplaceResult.copiedToClipboard)
        XCTAssertNotEqual(ReplaceResult.replaced, ReplaceResult.copiedToClipboard)
        XCTAssertNotEqual(ReplaceResult.replaced, ReplaceResult.fallbackClipboard)
    }

    // MARK: - ReplaceError Cases

    func testReplaceErrorCases() {
        let axError = ReplaceError.replaceFailedAX
        let clipError = ReplaceError.replaceFailedClipboard
        XCTAssertNotEqual(axError, clipError)
    }

    // MARK: - Strategy Fallthrough Behavior (via mock)

    func testAllThreeResultsArePossible() async throws {
        // Verify the mock can return each result type
        for expected: ReplaceResult in [.replaced, .fallbackClipboard, .copiedToClipboard] {
            sut.resultToReturn = expected
            let result = try await sut.replaceSelectedText(with: "test")
            XCTAssertEqual(result, expected)
        }
    }
}
