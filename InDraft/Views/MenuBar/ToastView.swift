import SwiftUI

enum ToastType {
    case success(String)
    case error(String)
    case info(String)

    var message: String {
        switch self {
        case .success(let msg), .error(let msg), .info(let msg): return msg
        }
    }

    var dismissDelay: TimeInterval {
        switch self {
        case .success: return Constants.Defaults.toastSuccessDismiss
        case .error, .info: return Constants.Defaults.toastErrorDismiss
        }
    }

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "exclamationmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .success: return Theme.Colors.accent
        case .error: return Theme.Colors.error
        case .info: return Theme.Colors.textSecondary
        }
    }
}

@MainActor
final class ToastManager: ObservableObject {
    @Published var currentToast: ToastType?
    private var dismissTask: Task<Void, Never>?

    func show(_ toast: ToastType) {
        dismissTask?.cancel()
        currentToast = toast
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(toast.dismissDelay))
            guard !Task.isCancelled else { return }
            currentToast = nil
        }
    }

    func dismiss() {
        dismissTask?.cancel()
        currentToast = nil
    }
}

struct ToastView: View {
    let toast: ToastType

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: toast.icon)
                .foregroundColor(toast.iconColor)
                .font(.system(size: 14))

            Text(toast.message)
                .font(Theme.Typography.body(12))
                .foregroundColor(Theme.Colors.textPrimary)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.sm)
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.md)
                .stroke(Theme.Colors.cardBorder, lineWidth: 1)
        )
        .shadow(color: Theme.Colors.textPrimary.opacity(0.08), radius: 8, y: 4)
    }
}
