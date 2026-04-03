import XCTest
import SwiftData
@testable import InDraft

final class HistoryServiceTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var service: LiveHistoryService!

    override func setUp() {
        super.setUp()
        let schema = Schema([Action.self, Provider.self, HistoryRecord.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
        service = LiveHistoryService(modelContext: context)
    }

    override func tearDown() {
        service = nil
        container = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Record Creation

    func testRecordSuccess() throws {
        service.recordSuccess(
            sourceApp: "Slack",
            actionID: UUID(),
            actionName: "Rewrite for Clarity",
            providerID: UUID(),
            providerName: "OpenAI",
            modelName: "gpt-4o",
            originalText: "rough text",
            transformedText: "polished text",
            latencyMs: 450
        )

        let records = service.allRecords()
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.status, .success)
        XCTAssertEqual(records.first?.originalText, "rough text")
        XCTAssertEqual(records.first?.transformedText, "polished text")
        XCTAssertEqual(records.first?.latencyMs, 450)
    }

    func testRecordError() throws {
        service.recordError(
            sourceApp: "Safari",
            actionID: nil,
            actionName: "Grammar Fix",
            providerID: nil,
            providerName: "OpenAI",
            modelName: "gpt-4o",
            originalText: "some text",
            latencyMs: 100,
            errorCode: "provider_auth",
            errorMessage: "Authentication failed"
        )

        let records = service.allRecords()
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.status, .error)
        XCTAssertEqual(records.first?.errorCode, "provider_auth")
        XCTAssertNil(records.first?.transformedText)
    }

    // MARK: - Search

    func testSearchByActionName() {
        service.recordSuccess(sourceApp: "S", actionID: nil, actionName: "Rewrite for Clarity", providerID: nil, providerName: "P", modelName: "M", originalText: "t", transformedText: "t2", latencyMs: 0)
        service.recordSuccess(sourceApp: "S", actionID: nil, actionName: "Grammar Fix", providerID: nil, providerName: "P", modelName: "M", originalText: "t", transformedText: "t2", latencyMs: 0)

        let results = service.search(query: "Rewrite")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.actionName, "Rewrite for Clarity")
    }

    func testSearchBySourceApp() {
        service.recordSuccess(sourceApp: "Slack", actionID: nil, actionName: "A", providerID: nil, providerName: "P", modelName: "M", originalText: "t", transformedText: "t2", latencyMs: 0)
        service.recordSuccess(sourceApp: "Safari", actionID: nil, actionName: "A", providerID: nil, providerName: "P", modelName: "M", originalText: "t", transformedText: "t2", latencyMs: 0)

        let results = service.search(query: "Slack")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.sourceApp, "Slack")
    }

    func testSearchByOriginalText() {
        service.recordSuccess(sourceApp: "S", actionID: nil, actionName: "A", providerID: nil, providerName: "P", modelName: "M", originalText: "hello world", transformedText: "t2", latencyMs: 0)

        let results = service.search(query: "hello")
        XCTAssertEqual(results.count, 1)
    }

    // MARK: - Delete

    func testDeleteRecord() {
        service.recordSuccess(sourceApp: "S", actionID: nil, actionName: "A", providerID: nil, providerName: "P", modelName: "M", originalText: "t", transformedText: "t2", latencyMs: 0)

        let records = service.allRecords()
        XCTAssertEqual(records.count, 1)

        service.deleteRecord(records.first!.id)
        XCTAssertEqual(service.allRecords().count, 0)
    }

    func testClearAll() {
        for i in 0..<5 {
            service.recordSuccess(sourceApp: "S\(i)", actionID: nil, actionName: "A", providerID: nil, providerName: "P", modelName: "M", originalText: "t", transformedText: "t2", latencyMs: 0)
        }
        XCTAssertEqual(service.allRecords().count, 5)

        service.clearAll()
        XCTAssertEqual(service.allRecords().count, 0)
    }

    // MARK: - Retention Pruning

    func testPruneOldRecords() {
        // Insert an old record
        let oldRecord = HistoryRecord(
            timestamp: Calendar.current.date(byAdding: .day, value: -31, to: Date())!,
            sourceApp: "Old",
            actionName: "A",
            providerName: "P",
            modelName: "M",
            originalText: "old",
            latencyMs: 0,
            status: .success
        )
        context.insert(oldRecord)

        // Insert a recent record
        service.recordSuccess(sourceApp: "Recent", actionID: nil, actionName: "A", providerID: nil, providerName: "P", modelName: "M", originalText: "recent", transformedText: "t2", latencyMs: 0)

        XCTAssertEqual(service.allRecords().count, 2)

        service.pruneOldRecords(retentionDays: 30)
        let remaining = service.allRecords()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.sourceApp, "Recent")
    }

    // MARK: - Most Recent

    func testMostRecentRecord() {
        service.recordSuccess(sourceApp: "First", actionID: nil, actionName: "A", providerID: nil, providerName: "P", modelName: "M", originalText: "t1", transformedText: "t2", latencyMs: 0)

        // Small delay to ensure different timestamps
        let laterRecord = HistoryRecord(
            timestamp: Date().addingTimeInterval(60),
            sourceApp: "Second",
            actionName: "A",
            providerName: "P",
            modelName: "M",
            originalText: "t3",
            transformedText: "t4",
            latencyMs: 0,
            status: .success
        )
        context.insert(laterRecord)
        try? context.save()

        let most = service.mostRecentRecord()
        XCTAssertEqual(most?.sourceApp, "Second")
    }

    func testMostRecentRecordWhenEmpty() {
        XCTAssertNil(service.mostRecentRecord())
    }

    // MARK: - Reverse Chronological Order

    func testAllRecordsInReverseChronologicalOrder() {
        for i in 0..<3 {
            let record = HistoryRecord(
                timestamp: Date().addingTimeInterval(Double(i) * 60),
                sourceApp: "App\(i)",
                actionName: "A",
                providerName: "P",
                modelName: "M",
                originalText: "t",
                latencyMs: 0,
                status: .success
            )
            context.insert(record)
        }
        try? context.save()

        let records = service.allRecords()
        XCTAssertEqual(records.first?.sourceApp, "App2")
        XCTAssertEqual(records.last?.sourceApp, "App0")
    }
}
