import Foundation
import SwiftData

protocol HistoryServiceProtocol {
    func recordSuccess(
        sourceApp: String,
        actionID: UUID?,
        actionName: String,
        providerID: UUID?,
        providerName: String,
        modelName: String,
        originalText: String,
        transformedText: String,
        latencyMs: Int
    )

    func recordError(
        sourceApp: String,
        actionID: UUID?,
        actionName: String,
        providerID: UUID?,
        providerName: String,
        modelName: String,
        originalText: String,
        latencyMs: Int,
        errorCode: String,
        errorMessage: String
    )

    func search(query: String) -> [HistoryRecord]
    func deleteRecord(_ id: UUID)
    func clearAll()
    func pruneOldRecords(retentionDays: Int)
    func mostRecentRecord() -> HistoryRecord?
    func allRecords() -> [HistoryRecord]
}

final class LiveHistoryService: HistoryServiceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func recordSuccess(
        sourceApp: String,
        actionID: UUID?,
        actionName: String,
        providerID: UUID?,
        providerName: String,
        modelName: String,
        originalText: String,
        transformedText: String,
        latencyMs: Int
    ) {
        let record = HistoryRecord(
            sourceApp: sourceApp,
            actionID: actionID,
            actionName: actionName,
            providerID: providerID,
            providerName: providerName,
            modelName: modelName,
            originalText: originalText,
            transformedText: transformedText,
            latencyMs: latencyMs,
            status: .success
        )
        modelContext.insert(record)
        try? modelContext.save()
    }

    func recordError(
        sourceApp: String,
        actionID: UUID?,
        actionName: String,
        providerID: UUID?,
        providerName: String,
        modelName: String,
        originalText: String,
        latencyMs: Int,
        errorCode: String,
        errorMessage: String
    ) {
        let record = HistoryRecord(
            sourceApp: sourceApp,
            actionID: actionID,
            actionName: actionName,
            providerID: providerID,
            providerName: providerName,
            modelName: modelName,
            originalText: originalText,
            latencyMs: latencyMs,
            status: .error,
            errorCode: errorCode,
            errorMessage: errorMessage
        )
        modelContext.insert(record)
        try? modelContext.save()
    }

    func search(query: String) -> [HistoryRecord] {
        let predicate = #Predicate<HistoryRecord> {
            $0.actionName.localizedStandardContains(query) ||
            $0.sourceApp.localizedStandardContains(query) ||
            $0.originalText.localizedStandardContains(query) ||
            ($0.transformedText?.localizedStandardContains(query) ?? false)
        }
        let descriptor = FetchDescriptor<HistoryRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func deleteRecord(_ id: UUID) {
        let predicate = #Predicate<HistoryRecord> { $0.id == id }
        let descriptor = FetchDescriptor<HistoryRecord>(predicate: predicate)
        if let record = try? modelContext.fetch(descriptor).first {
            modelContext.delete(record)
            try? modelContext.save()
        }
    }

    func clearAll() {
        let descriptor = FetchDescriptor<HistoryRecord>()
        if let all = try? modelContext.fetch(descriptor) {
            for record in all {
                modelContext.delete(record)
            }
            try? modelContext.save()
        }
    }

    func pruneOldRecords(retentionDays: Int) {
        guard retentionDays > 0 else { return }
        let cutoff = Calendar.current.date(byAdding: .day, value: -retentionDays, to: Date())!
        let predicate = #Predicate<HistoryRecord> { $0.timestamp < cutoff }
        let descriptor = FetchDescriptor<HistoryRecord>(predicate: predicate)
        if let old = try? modelContext.fetch(descriptor) {
            for record in old {
                modelContext.delete(record)
            }
            try? modelContext.save()
        }
    }

    func mostRecentRecord() -> HistoryRecord? {
        var descriptor = FetchDescriptor<HistoryRecord>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }

    func allRecords() -> [HistoryRecord] {
        let descriptor = FetchDescriptor<HistoryRecord>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
