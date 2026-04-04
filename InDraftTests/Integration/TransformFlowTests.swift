import XCTest
import SwiftData
@testable import InDraft

/// Integration tests for the full transformation pipeline using mocks.
/// Real AX/clipboard operations require Accessibility permissions and must be tested manually.
final class TransformFlowTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() {
        super.setUp()
        let schema = Schema([Action.self, Provider.self, HistoryRecord.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    // MARK: - Full Pipeline (Mocked)

    func testFullTransformPipeline_Replace() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .success("rough draft text")
        let replace = MockTextReplaceService()
        replace.resultToReturn = .replaced
        let provider = MockProviderService()
        provider.transformResult = .success("polished text")
        let history = LiveHistoryService(modelContext: context)

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider,
            historyService: history
        )

        let action = Action(name: "Rewrite for Clarity", prompt: "Rewrite clearly", outputBehavior: .replace)
        let prov = Provider(displayName: "OpenAI", baseURL: "https://api.openai.com/v1", defaultModel: "gpt-4o", isActive: true)

        let (result, error) = await service.execute(action: action, provider: prov, apiKey: "test-key")

        XCTAssertNil(error)
        if case .replaced = result {} else {
            XCTFail("Expected .replaced")
        }

        // Verify history recorded
        let records = history.allRecords()
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.status, .success)
        XCTAssertEqual(records.first?.actionName, "Rewrite for Clarity")
        XCTAssertEqual(records.first?.originalText, "rough draft text")
        XCTAssertEqual(records.first?.transformedText, "polished text")
    }

    func testFullTransformPipeline_Preview() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .success("original text")
        let replace = MockTextReplaceService()
        let provider = MockProviderService()
        provider.transformResult = .success("improved text")

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider
        )

        let action = Action(name: "Preview Action", prompt: "Improve", outputBehavior: .preview)
        let prov = Provider(displayName: "OpenAI", baseURL: "https://api.openai.com/v1", defaultModel: "gpt-4o")

        let (result, error) = await service.execute(action: action, provider: prov, apiKey: "key")

        XCTAssertNil(error)
        if case .previewing(let orig, let trans) = result {
            XCTAssertEqual(orig, "original text")
            XCTAssertEqual(trans, "improved text")
        } else {
            XCTFail("Expected .previewing")
        }
    }

    func testFullTransformPipeline_Clipboard() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .success("some text")
        let replace = MockTextReplaceService()
        let provider = MockProviderService()
        provider.transformResult = .success("transformed text")

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider
        )

        let action = Action(name: "Clipboard Action", prompt: "Transform", outputBehavior: .clipboard)
        let prov = Provider(displayName: "OpenAI", baseURL: "https://api.openai.com/v1", defaultModel: "gpt-4o")

        let (result, error) = await service.execute(action: action, provider: prov, apiKey: "key")

        XCTAssertNil(error)
        if case .copiedToClipboard = result {} else {
            XCTFail("Expected .copiedToClipboard")
        }
    }

    // MARK: - Error Paths

    func testErrorPath_NoTextSelected() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .failure(.noTextSelected)
        let replace = MockTextReplaceService()
        let provider = MockProviderService()

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider
        )

        let action = Action(name: "Test", prompt: "Test", outputBehavior: .replace)
        let prov = Provider(displayName: "P", baseURL: "https://a.com/v1", defaultModel: "m")

        let (result, error) = await service.execute(action: action, provider: prov, apiKey: "key")

        XCTAssertNil(result)
        if case .noTextSelected = error {} else {
            XCTFail("Expected .noTextSelected, got \(String(describing: error))")
        }
    }

    func testErrorPath_ProviderAuthFailure() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .success("text")
        let replace = MockTextReplaceService()
        let provider = MockProviderService()
        provider.transformResult = .failure(ProviderError.authFailed)
        let history = LiveHistoryService(modelContext: context)

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider,
            historyService: history
        )

        let action = Action(name: "Test", prompt: "Test", outputBehavior: .replace)
        let prov = Provider(displayName: "P", baseURL: "https://a.com/v1", defaultModel: "m")

        let (result, error) = await service.execute(action: action, provider: prov, apiKey: "bad-key")

        XCTAssertNil(result)
        if case .providerFailed = error {} else {
            XCTFail("Expected .providerFailed")
        }

        // Verify error recorded in history
        let records = history.allRecords()
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.status, .error)
        XCTAssertEqual(records.first?.errorCode, "provider_failed")
    }

    func testErrorPath_ReplacementFallback() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .success("text")
        let replace = MockTextReplaceService()
        replace.resultToReturn = .copiedToClipboard
        let provider = MockProviderService()
        provider.transformResult = .success("result")

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider
        )

        let action = Action(name: "Test", prompt: "Test", outputBehavior: .replace)
        let prov = Provider(displayName: "P", baseURL: "https://a.com/v1", defaultModel: "m")

        let (result, error) = await service.execute(action: action, provider: prov, apiKey: "key")

        XCTAssertNil(error)
        if case .copiedToClipboard = result {} else {
            XCTFail("Expected .copiedToClipboard fallback")
        }
    }

    func testErrorPath_BothCaptureFail() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .failure(.bothFailed)
        let replace = MockTextReplaceService()
        let provider = MockProviderService()
        let history = LiveHistoryService(modelContext: context)

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider,
            historyService: history
        )

        let action = Action(name: "Test", prompt: "Test", outputBehavior: .replace)
        let prov = Provider(displayName: "P", baseURL: "https://a.com/v1", defaultModel: "m")

        let (result, error) = await service.execute(action: action, provider: prov, apiKey: "key")

        XCTAssertNil(result)
        if case .captureFailed = error {} else {
            XCTFail("Expected .captureFailed")
        }

        // Verify error recorded
        let records = history.allRecords()
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.status, .error)
    }

    // MARK: - App Lifecycle

    @MainActor
    func testAppDelegateExists() {
        let delegate = AppDelegate()
        XCTAssertNotNil(delegate)
    }

    func testSeedDataCreatesDefaultsOnFirstLaunch() throws {
        SeedData.createDefaultActions(in: context)
        let actions = try context.fetch(FetchDescriptor<Action>(sortBy: [SortDescriptor(\.sortOrder)]))
        XCTAssertEqual(actions.count, 3)
        XCTAssertEqual(actions[0].name, "Grammar Fix")
        XCTAssertTrue(actions[0].hasHotkey)
    }
}
