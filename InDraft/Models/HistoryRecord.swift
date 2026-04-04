import Foundation
import SwiftData

enum TransformationStatus: String, Codable {
    case success
    case error
}

@Model
final class HistoryRecord {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var sourceApp: String
    var actionID: UUID?
    var actionName: String
    var providerID: UUID?
    var providerName: String
    var modelName: String
    var originalText: String
    var transformedText: String?
    var latencyMs: Int
    var status: TransformationStatus
    var errorCode: String?
    var errorMessage: String?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        sourceApp: String,
        actionID: UUID? = nil,
        actionName: String,
        providerID: UUID? = nil,
        providerName: String,
        modelName: String,
        originalText: String,
        transformedText: String? = nil,
        latencyMs: Int = 0,
        status: TransformationStatus,
        errorCode: String? = nil,
        errorMessage: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.sourceApp = sourceApp
        self.actionID = actionID
        self.actionName = actionName
        self.providerID = providerID
        self.providerName = providerName
        self.modelName = modelName
        self.originalText = originalText
        self.transformedText = transformedText
        self.latencyMs = latencyMs
        self.status = status
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}
