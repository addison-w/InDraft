import XCTest
@testable import InDraft

final class DiffServiceTests: XCTestCase {
    var service: LiveDiffService!

    override func setUp() {
        super.setUp()
        service = LiveDiffService()
    }

    // MARK: - Basic Cases

    func testIdenticalStringsReturnsAllUnchanged() {
        let text = "Hello world today"
        let result = service.computeWordDiff(original: text, transformed: text)

        XCTAssertNotNil(result)
        guard let segments = result else { return }
        XCTAssertEqual(segments.count, 1)
        XCTAssertEqual(segments[0].type, .unchanged)
        XCTAssertTrue(segments[0].text.contains("Hello"))
        XCTAssertTrue(segments[0].text.contains("world"))
        XCTAssertTrue(segments[0].text.contains("today"))
    }

    func testBothEmptyStringsReturnsEmptyResult() {
        let result = service.computeWordDiff(original: "", transformed: "")

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 0)
    }

    func testOriginalEmptyReturnsAllInserted() {
        let result = service.computeWordDiff(original: "", transformed: "hello world")

        XCTAssertNotNil(result)
        guard let segments = result else { return }
        XCTAssertEqual(segments.count, 1)
        XCTAssertEqual(segments[0].type, .inserted)
        XCTAssertTrue(segments[0].text.contains("hello"))
        XCTAssertTrue(segments[0].text.contains("world"))
    }

    func testTransformedEmptyReturnsAllRemoved() {
        let result = service.computeWordDiff(original: "hello world", transformed: "")

        XCTAssertNotNil(result)
        guard let segments = result else { return }
        XCTAssertEqual(segments.count, 1)
        XCTAssertEqual(segments[0].type, .removed)
        XCTAssertTrue(segments[0].text.contains("hello"))
        XCTAssertTrue(segments[0].text.contains("world"))
    }

    func testCompletelyDifferentStrings() {
        let result = service.computeWordDiff(original: "aaa bbb", transformed: "xxx yyy")

        XCTAssertNotNil(result)
        guard let segments = result else { return }

        let removedSegments = segments.filter { $0.type == .removed }
        let insertedSegments = segments.filter { $0.type == .inserted }
        let unchangedSegments = segments.filter { $0.type == .unchanged }

        XCTAssertFalse(removedSegments.isEmpty)
        XCTAssertFalse(insertedSegments.isEmpty)
        XCTAssertTrue(unchangedSegments.isEmpty)

        let removedText = removedSegments.map { $0.text }.joined()
        XCTAssertTrue(removedText.contains("aaa"))
        XCTAssertTrue(removedText.contains("bbb"))

        let insertedText = insertedSegments.map { $0.text }.joined()
        XCTAssertTrue(insertedText.contains("xxx"))
        XCTAssertTrue(insertedText.contains("yyy"))
    }

    // MARK: - Word Insertion

    func testWordInsertionInMiddle() {
        let result = service.computeWordDiff(
            original: "the cat sat",
            transformed: "the big cat sat"
        )

        XCTAssertNotNil(result)
        guard let segments = result else { return }

        let types = segments.map { $0.type }
        XCTAssertTrue(types.contains(.unchanged))
        XCTAssertTrue(types.contains(.inserted))

        let insertedText = segments.filter { $0.type == .inserted }.map { $0.text }.joined()
        XCTAssertTrue(insertedText.contains("big"))
    }

    func testWordInsertionAtEnd() {
        let result = service.computeWordDiff(
            original: "hello world",
            transformed: "hello world today"
        )

        XCTAssertNotNil(result)
        guard let segments = result else { return }

        let insertedText = segments.filter { $0.type == .inserted }.map { $0.text }.joined()
        XCTAssertTrue(insertedText.contains("today"))
    }

    // MARK: - Word Removal

    func testWordRemovalFromMiddle() {
        let result = service.computeWordDiff(
            original: "the big cat sat",
            transformed: "the cat sat"
        )

        XCTAssertNotNil(result)
        guard let segments = result else { return }

        let types = segments.map { $0.type }
        XCTAssertTrue(types.contains(.unchanged))
        XCTAssertTrue(types.contains(.removed))

        let removedText = segments.filter { $0.type == .removed }.map { $0.text }.joined()
        XCTAssertTrue(removedText.contains("big"))
    }

    func testWordRemovalFromEnd() {
        let result = service.computeWordDiff(
            original: "hello world today",
            transformed: "hello world"
        )

        XCTAssertNotNil(result)
        guard let segments = result else { return }

        let removedText = segments.filter { $0.type == .removed }.map { $0.text }.joined()
        XCTAssertTrue(removedText.contains("today"))
    }

    // MARK: - Mixed Changes

    func testMixedInsertionAndRemoval() {
        let result = service.computeWordDiff(
            original: "I like cats very much",
            transformed: "I love cats so much"
        )

        XCTAssertNotNil(result)
        guard let segments = result else { return }

        let types = segments.map { $0.type }
        XCTAssertTrue(types.contains(.unchanged))
        XCTAssertTrue(types.contains(.inserted))
        XCTAssertTrue(types.contains(.removed))

        let unchangedText = segments.filter { $0.type == .unchanged }.map { $0.text }.joined()
        XCTAssertTrue(unchangedText.contains("I"))
        XCTAssertTrue(unchangedText.contains("cats"))
        XCTAssertTrue(unchangedText.contains("much"))
    }

    func testWordReplacement() {
        let result = service.computeWordDiff(
            original: "the quick fox",
            transformed: "the slow fox"
        )

        XCTAssertNotNil(result)
        guard let segments = result else { return }

        let removedText = segments.filter { $0.type == .removed }.map { $0.text }.joined()
        XCTAssertTrue(removedText.contains("quick"))

        let insertedText = segments.filter { $0.type == .inserted }.map { $0.text }.joined()
        XCTAssertTrue(insertedText.contains("slow"))

        let unchangedText = segments.filter { $0.type == .unchanged }.map { $0.text }.joined()
        XCTAssertTrue(unchangedText.contains("the"))
        XCTAssertTrue(unchangedText.contains("fox"))
    }

    // MARK: - Performance Guard

    func testLargeTextOriginalReturnsNil() {
        let largeText = Array(repeating: "word", count: 10_001).joined(separator: " ")
        let result = service.computeWordDiff(original: largeText, transformed: "small")

        XCTAssertNil(result)
    }

    func testLargeTextTransformedReturnsNil() {
        let largeText = Array(repeating: "word", count: 10_001).joined(separator: " ")
        let result = service.computeWordDiff(original: "small", transformed: largeText)

        XCTAssertNil(result)
    }

    func testExactlyAtLimitReturnsResult() {
        let text = Array(repeating: "word", count: 10_000).joined(separator: " ")
        let result = service.computeWordDiff(original: text, transformed: text)

        XCTAssertNotNil(result)
    }

    // MARK: - Whitespace and Line Breaks

    func testPreservesLineBreaks() {
        let original = "hello\nworld\ntoday"
        let transformed = "hello\nworld\ntoday"
        let result = service.computeWordDiff(original: original, transformed: transformed)

        XCTAssertNotNil(result)
        guard let segments = result else { return }

        let fullText = segments.map { $0.text }.joined()
        XCTAssertTrue(fullText.contains("\n"))
    }

    func testMultipleSpacesBetweenWords() {
        let result = service.computeWordDiff(
            original: "hello   world",
            transformed: "hello   world"
        )

        XCTAssertNotNil(result)
        guard let segments = result else { return }
        XCTAssertEqual(segments.count, 1)
        XCTAssertEqual(segments[0].type, .unchanged)
    }

    func testDiffAcrossLineBreaks() {
        let result = service.computeWordDiff(
            original: "line one\nline two",
            transformed: "line one\nline three"
        )

        XCTAssertNotNil(result)
        guard let segments = result else { return }

        let removedText = segments.filter { $0.type == .removed }.map { $0.text }.joined()
        XCTAssertTrue(removedText.contains("two"))

        let insertedText = segments.filter { $0.type == .inserted }.map { $0.text }.joined()
        XCTAssertTrue(insertedText.contains("three"))
    }

    // MARK: - Segment Coalescing

    func testAdjacentSameTypeSegmentsAreCoalesced() {
        // When multiple adjacent words are all inserted, they should be one segment
        let result = service.computeWordDiff(
            original: "start end",
            transformed: "start aaa bbb ccc end"
        )

        XCTAssertNotNil(result)
        guard let segments = result else { return }

        let insertedSegments = segments.filter { $0.type == .inserted }
        // All inserted words should be coalesced into one segment
        XCTAssertEqual(insertedSegments.count, 1)
        XCTAssertTrue(insertedSegments[0].text.contains("aaa"))
        XCTAssertTrue(insertedSegments[0].text.contains("bbb"))
        XCTAssertTrue(insertedSegments[0].text.contains("ccc"))
    }

    // MARK: - Single Word

    func testSingleWordUnchanged() {
        let result = service.computeWordDiff(original: "hello", transformed: "hello")

        XCTAssertNotNil(result)
        guard let segments = result else { return }
        XCTAssertEqual(segments.count, 1)
        XCTAssertEqual(segments[0].type, .unchanged)
    }

    func testSingleWordReplaced() {
        let result = service.computeWordDiff(original: "hello", transformed: "goodbye")

        XCTAssertNotNil(result)
        guard let segments = result else { return }

        let types = segments.map { $0.type }
        XCTAssertTrue(types.contains(.removed))
        XCTAssertTrue(types.contains(.inserted))
        XCTAssertFalse(types.contains(.unchanged))
    }

    // MARK: - Mock Service

    func testMockServiceReturnsConfiguredResult() {
        let mock = MockDiffService()
        let expected = [DiffSegment(type: .unchanged, text: "test")]
        mock.resultToReturn = expected

        let result = mock.computeWordDiff(original: "a", transformed: "b")

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?[0].type, .unchanged)
        XCTAssertEqual(result?[0].text, "test")
    }

    func testMockServiceReturnsNilWhenConfigured() {
        let mock = MockDiffService()
        mock.resultToReturn = nil

        let result = mock.computeWordDiff(original: "a", transformed: "b")

        XCTAssertNil(result)
    }
}
