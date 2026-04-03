import XCTest
import SwiftData
@testable import InDraft

final class HistoryRecordTests: XCTestCase {
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

    func testHistoryRecordCreatedWithAllFields() {
        let actionID = UUID()
        let providerID = UUID()
        let record = HistoryRecord(
            sourceApp: "Slack",
            actionID: actionID,
            actionName: "Rewrite for Clarity",
            providerID: providerID,
            providerName: "OpenAI",
            modelName: "gpt-4o",
            originalText: "this is rough text",
            transformedText: "This is polished text.",
            latencyMs: 450,
            status: .success
        )
        context.insert(record)
        try! context.save()

        XCTAssertFalse(record.id.uuidString.isEmpty)
        XCTAssertEqual(record.sourceApp, "Slack")
        XCTAssertEqual(record.actionID, actionID)
        XCTAssertEqual(record.actionName, "Rewrite for Clarity")
        XCTAssertEqual(record.providerID, providerID)
        XCTAssertEqual(record.providerName, "OpenAI")
        XCTAssertEqual(record.modelName, "gpt-4o")
        XCTAssertEqual(record.originalText, "this is rough text")
        XCTAssertEqual(record.transformedText, "This is polished text.")
        XCTAssertEqual(record.latencyMs, 450)
        XCTAssertEqual(record.status, .success)
        XCTAssertNil(record.errorCode)
        XCTAssertNil(record.errorMessage)
    }

    // MARK: - Error Records

    func testErrorRecordWithDetails() {
        let record = HistoryRecord(
            sourceApp: "Safari",
            actionName: "Grammar Fix",
            providerName: "OpenAI",
            modelName: "gpt-4o",
            originalText: "some text",
            latencyMs: 100,
            status: .error,
            errorCode: "provider_auth",
            errorMessage: "Authentication failed — check your API key"
        )
        context.insert(record)
        try! context.save()

        XCTAssertEqual(record.status, .error)
        XCTAssertEqual(record.errorCode, "provider_auth")
        XCTAssertEqual(record.errorMessage, "Authentication failed — check your API key")
        XCTAssertNil(record.transformedText)
    }

    // MARK: - Snapshot Names (History readable after deletion)

    func testSnapshotNamesAreIndependentOfRelationships() throws {
        // History stores names as copies, not foreign key references
        let record = HistoryRecord(
            sourceApp: "TextEdit",
            actionID: UUID(), // This action could be deleted later
            actionName: "My Custom Action",
            providerID: UUID(), // This provider could be deleted later
            providerName: "My Custom Provider",
            modelName: "gpt-4o",
            originalText: "test",
            transformedText: "tested",
            latencyMs: 200,
            status: .success
        )
        context.insert(record)
        try context.save()

        // Even if action/provider UUIDs no longer exist, names remain
        let fetched = try context.fetch(FetchDescriptor<HistoryRecord>())
        XCTAssertEqual(fetched.first?.actionName, "My Custom Action")
        XCTAssertEqual(fetched.first?.providerName, "My Custom Provider")
    }

    // MARK: - Status Enum

    func testTransformationStatusCases() {
        let success = TransformationStatus.success
        let error = TransformationStatus.error
        XCTAssertEqual(success.rawValue, "success")
        XCTAssertEqual(error.rawValue, "error")
    }

    // MARK: - Retention Pruning

    func testRetentionPruning() throws {
        let oldDate = Calendar.current.date(byAdding: .day, value: -31, to: Date())!
        let recentDate = Date()

        let old = HistoryRecord(
            timestamp: oldDate,
            sourceApp: "Old",
            actionName: "A",
            providerName: "P",
            modelName: "M",
            originalText: "old",
            latencyMs: 0,
            status: .success
        )
        let recent = HistoryRecord(
            timestamp: recentDate,
            sourceApp: "Recent",
            actionName: "A",
            providerName: "P",
            modelName: "M",
            originalText: "recent",
            latencyMs: 0,
            status: .success
        )
        context.insert(old)
        context.insert(recent)
        try context.save()

        // Simulate retention pruning: delete records older than 30 days
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let predicate = #Predicate<HistoryRecord> { $0.timestamp < cutoff }
        let toDelete = try context.fetch(FetchDescriptor<HistoryRecord>(predicate: predicate))
        for record in toDelete {
            context.delete(record)
        }
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<HistoryRecord>())
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.sourceApp, "Recent")
    }

    // MARK: - Persistence & Fetch Order

    func testRecordsInReverseChronologicalOrder() throws {
        for i in 0..<5 {
            let record = HistoryRecord(
                timestamp: Date().addingTimeInterval(Double(i) * 60),
                sourceApp: "App\(i)",
                actionName: "Action",
                providerName: "Provider",
                modelName: "Model",
                originalText: "text\(i)",
                latencyMs: 100,
                status: .success
            )
            context.insert(record)
        }
        try context.save()

        let descriptor = FetchDescriptor<HistoryRecord>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched.count, 5)
        XCTAssertEqual(fetched.first?.sourceApp, "App4")
        XCTAssertEqual(fetched.last?.sourceApp, "App0")
    }
}
