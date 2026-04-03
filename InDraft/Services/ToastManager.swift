import Foundation
import Combine

enum ToastType {
    case success
    case error
    case info
}

struct ToastItem: Equatable {
    let message: String
    let type: ToastType
    let id = UUID()

    static func == (lhs: ToastItem, rhs: ToastItem) -> Bool {
        lhs.id == rhs.id
    }

    static func success(_ message: String) -> ToastItem {
        ToastItem(message: message, type: .success)
    }

    static func error(_ message: String) -> ToastItem {
        ToastItem(message: message, type: .error)
    }

    static func info(_ message: String) -> ToastItem {
        ToastItem(message: message, type: .info)
    }
}

@MainActor
final class ToastManager: ObservableObject {
    @Published var currentToast: ToastItem?

    private var dismissTask: Task<Void, Never>?

    func show(_ toast: ToastItem) {
        dismissTask?.cancel()
        currentToast = toast

        // Auto-dismiss after a delay based on type
        let delay: TimeInterval = switch toast.type {
        case .success: 2.0
        case .error: 5.0
        case .info: 3.0
        }

        dismissTask = Task {
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            currentToast = nil
        }
    }

    func dismiss() {
        dismissTask?.cancel()
        currentToast = nil
    }
}