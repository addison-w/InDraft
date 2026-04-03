import Foundation
import Combine

enum AppStatus: Equatable {
    case idle
    case processing
    case success
    case error(message: String)
    case permissionRequired
}

@MainActor
final class AppState: ObservableObject {
    @Published var status: AppStatus = .idle

    private var dismissTask: Task<Void, Never>?

    func setProcessing() {
        dismissTask?.cancel()
        status = .processing
    }

    func setSuccess() {
        dismissTask?.cancel()
        status = .success
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            status = .idle
        }
    }

    func setError(_ message: String) {
        dismissTask?.cancel()
        status = .error(message: message)
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(10))
            guard !Task.isCancelled else { return }
            status = .idle
        }
    }

    func setPermissionRequired() {
        dismissTask?.cancel()
        status = .permissionRequired
    }

    func setIdle() {
        dismissTask?.cancel()
        status = .idle
    }
}
