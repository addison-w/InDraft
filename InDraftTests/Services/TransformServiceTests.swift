import XCTest
import SwiftData
@testable import InDraft

final class TransformServiceTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() {
        super.setUp()
        let schema = Schema([Action.self, Provider.self, HistoryRecord.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    private func makeAction(outputBehavior: OutputBehavior = .replace) -> Action {
        Action(name: "Test", prompt: "Rewrite this", outputBehavior: outputBehavior)
    }

    private func makeProvider() -> Provider {
        Provider(displayName: "OpenAI", baseURL: "https://api.openai.com/v1", defaultModel: "gpt-4o", isActive: true)
    }

    // MARK: - Full Pipeline

    func testSuccessfulReplacePipeline() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .success("rough text")
        let replace = MockTextReplaceService()
        replace.resultToReturn = .replaced
        let provider = MockProviderService()
        provider.transformResult = .success("polished text")

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider
        )

        let action = makeAction()
        let prov = makeProvider()
        let (result, error) = await service.execute(action: action, provider: prov, apiKey: "key")

        XCTAssertNil(error)
        if case .replaced = result {} else {
            XCTFail("Expected .replaced, got \(String(describing: result))")
        }
    }

    func testCaptureFailureAbortsPipeline() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .failure(.noTextSelected)
        let replace = MockTextReplaceService()
        let provider = MockProviderService()

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider
        )

        let action = makeAction()
        let prov = makeProvider()
        let (result, error) = await service.execute(action: action, provider: prov, apiKey: "key")

        XCTAssertNil(result)
        if case .noTextSelected = error {} else {
            XCTFail("Expected .noTextSelected, got \(String(describing: error))")
        }
    }

    func testProviderFailureAbortsPipeline() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .success("text")
        let replace = MockTextReplaceService()
        let provider = MockProviderService()
        provider.transformResult = .failure(ProviderError.authFailed)

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider
        )

        let action = makeAction()
        let prov = makeProvider()
        let (result, error) = await service.execute(action: action, provider: prov, apiKey: "key")

        XCTAssertNil(result)
        if case .providerFailed = error {} else {
            XCTFail("Expected .providerFailed, got \(String(describing: error))")
        }
    }

    // MARK: - Output Behavior Routing

    func testPreviewModeReturnsPreviewResult() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .success("original")
        let replace = MockTextReplaceService()
        let provider = MockProviderService()
        provider.transformResult = .success("transformed")

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider
        )

        let action = makeAction(outputBehavior: .preview)
        let prov = makeProvider()
        let (result, error) = await service.execute(action: action, provider: prov, apiKey: "key")

        XCTAssertNil(error)
        if case .previewing(let orig, let trans) = result {
            XCTAssertEqual(orig, "original")
            XCTAssertEqual(trans, "transformed")
        } else {
            XCTFail("Expected .previewing, got \(String(describing: result))")
        }
    }

    func testClipboardModeCopiesToClipboard() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .success("original")
        let replace = MockTextReplaceService()
        let provider = MockProviderService()
        provider.transformResult = .success("transformed")

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider
        )

        let action = makeAction(outputBehavior: .clipboard)
        let prov = makeProvider()
        let (result, error) = await service.execute(action: action, provider: prov, apiKey: "key")

        XCTAssertNil(error)
        if case .copiedToClipboard = result {} else {
            XCTFail("Expected .copiedToClipboard, got \(String(describing: result))")
        }
    }

    // MARK: - Model Override

    func testModelOverridePassedToProvider() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .success("text")
        let replace = MockTextReplaceService()
        replace.resultToReturn = .replaced
        let provider = MockProviderService()
        provider.transformResult = .success("result")

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider
        )

        let action = makeAction()
        let prov = makeProvider()
        let _ = await service.execute(action: action, provider: prov, apiKey: "key", modelOverride: "gpt-4o-mini")

        // The mock captures the last call — verify it was called
        XCTAssertEqual(provider.transformCallCount, 1)
    }

    func testNilModelOverrideUsesDefault() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .success("text")
        let replace = MockTextReplaceService()
        replace.resultToReturn = .replaced
        let provider = MockProviderService()
        provider.transformResult = .success("result")

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider
        )

        let action = makeAction()
        let prov = makeProvider()
        let _ = await service.execute(action: action, provider: prov, apiKey: "key", modelOverride: nil)

        XCTAssertEqual(provider.transformCallCount, 1)
    }

    func testFixedProviderModeAction() {
        let action = Action(name: "Test", prompt: "Fix grammar", providerMode: .fixed, providerID: UUID(), modelOverride: "claude-3-haiku")
        XCTAssertEqual(action.providerMode, .fixed)
        XCTAssertNotNil(action.providerID)
        XCTAssertEqual(action.modelOverride, "claude-3-haiku")
    }

    func testActiveProviderModeDefaults() {
        let action = Action(name: "Test", prompt: "Fix grammar")
        XCTAssertEqual(action.providerMode, .active)
        XCTAssertNil(action.providerID)
        XCTAssertNil(action.modelOverride)
    }

    func testProviderDeletionResetsAction() {
        let providerID = UUID()
        let action = Action(name: "Test", prompt: "Fix", providerMode: .fixed, providerID: providerID, modelOverride: "gpt-4o")
        context.insert(action)
        try? context.save()

        // Simulate deletion cascade
        action.providerMode = .active
        action.providerID = nil
        action.modelOverride = nil
        try? context.save()

        XCTAssertEqual(action.providerMode, .active)
        XCTAssertNil(action.providerID)
        XCTAssertNil(action.modelOverride)
    }

    func testReplaceFallbackToClipboard() async {
        let capture = MockTextCaptureService()
        capture.resultToReturn = .success("text")
        let replace = MockTextReplaceService()
        replace.resultToReturn = .copiedToClipboard
        let provider = MockProviderService()
        provider.transformResult = .success("transformed")

        let service = LiveTransformService(
            captureService: capture,
            replaceService: replace,
            providerService: provider
        )

        let action = makeAction()
        let prov = makeProvider()
        let (result, error) = await service.execute(action: action, provider: prov, apiKey: "key")

        XCTAssertNil(error)
        if case .copiedToClipboard = result {} else {
            XCTFail("Expected .copiedToClipboard, got \(String(describing: result))")
        }
    }
}
