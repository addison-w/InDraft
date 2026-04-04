import Foundation
import SwiftData

enum TestStatus: String, Codable {
    case untested
    case success
    case failed
}

@Model
final class Provider {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var baseURL: String
    var apiKeyReference: String
    var defaultModel: String
    var enabled: Bool
    var isActive: Bool
    var lastTestStatus: TestStatus
    var lastTestError: String?
    var lastTestedAt: Date?
    var timeoutSeconds: Int = 60
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        displayName: String,
        baseURL: String,
        apiKeyReference: String = "",
        defaultModel: String,
        enabled: Bool = true,
        isActive: Bool = false,
        lastTestStatus: TestStatus = .untested,
        lastTestError: String? = nil,
        lastTestedAt: Date? = nil,
        timeoutSeconds: Int = 60,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.baseURL = baseURL
        self.apiKeyReference = apiKeyReference
        self.defaultModel = defaultModel
        self.enabled = enabled
        self.isActive = isActive
        self.lastTestStatus = lastTestStatus
        self.lastTestError = lastTestError
        self.lastTestedAt = lastTestedAt
        self.timeoutSeconds = timeoutSeconds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
