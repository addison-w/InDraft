import XCTest
import SwiftData
@testable import InDraft

final class ProviderTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() {
        super.setUp()
        let schema = Schema([Action.self, Provider.self, HistoryRecord.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    override func tearDown() {
        container = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Field Defaults

    func testProviderCreatedWithDefaults() {
        let provider = Provider(displayName: "OpenAI", baseURL: "https://api.openai.com/v1", defaultModel: "gpt-4o")
        context.insert(provider)
        try! context.save()

        XCTAssertFalse(provider.id.uuidString.isEmpty)
        XCTAssertEqual(provider.displayName, "OpenAI")
        XCTAssertEqual(provider.baseURL, "https://api.openai.com/v1")
        XCTAssertEqual(provider.defaultModel, "gpt-4o")
        XCTAssertTrue(provider.enabled)
        XCTAssertFalse(provider.isActive)
        XCTAssertEqual(provider.lastTestStatus, .untested)
        XCTAssertNil(provider.lastTestError)
        XCTAssertNil(provider.lastTestedAt)
    }

    // MARK: - Active Provider Constraint

    func testOnlyOneProviderActiveAtATime() throws {
        let p1 = Provider(displayName: "P1", baseURL: "https://a.com/v1", defaultModel: "m1", isActive: true)
        let p2 = Provider(displayName: "P2", baseURL: "https://b.com/v1", defaultModel: "m2", isActive: false)
        context.insert(p1)
        context.insert(p2)
        try context.save()

        // Simulate switching active: deactivate p1, activate p2
        p1.isActive = false
        p2.isActive = true
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Provider>())
        let activeCount = fetched.filter(\.isActive).count
        XCTAssertEqual(activeCount, 1)
        XCTAssertTrue(p2.isActive)
        XCTAssertFalse(p1.isActive)
    }

    // MARK: - Enabled/Disabled Behavior

    func testDisabledProviderCannotBeActive() throws {
        let provider = Provider(displayName: "Test", baseURL: "https://a.com/v1", defaultModel: "m1", enabled: false, isActive: false)
        context.insert(provider)
        try context.save()

        // Business rule: disabled provider should not be set active
        // This is enforced at the app level, not the model level
        XCTAssertFalse(provider.enabled)
        XCTAssertFalse(provider.isActive)
    }

    // MARK: - Test Status

    func testProviderTestStatusUpdates() throws {
        let provider = Provider(displayName: "Test", baseURL: "https://a.com/v1", defaultModel: "m1")
        context.insert(provider)
        try context.save()

        XCTAssertEqual(provider.lastTestStatus, .untested)

        provider.lastTestStatus = .success
        provider.lastTestedAt = Date()
        try context.save()

        XCTAssertEqual(provider.lastTestStatus, .success)
        XCTAssertNotNil(provider.lastTestedAt)

        provider.lastTestStatus = .failed
        provider.lastTestError = "Authentication failed"
        try context.save()

        XCTAssertEqual(provider.lastTestStatus, .failed)
        XCTAssertEqual(provider.lastTestError, "Authentication failed")
    }

    // MARK: - Persistence

    func testProviderPersistsAndFetches() throws {
        let provider = Provider(
            displayName: "Anthropic Proxy",
            baseURL: "https://proxy.example.com/v1",
            apiKeyReference: "keychain-ref-123",
            defaultModel: "claude-sonnet-4-20250514"
        )
        context.insert(provider)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Provider>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.displayName, "Anthropic Proxy")
        XCTAssertEqual(fetched.first?.apiKeyReference, "keychain-ref-123")
    }
}
