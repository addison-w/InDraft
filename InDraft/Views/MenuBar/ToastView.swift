import SwiftUI
import Hugeicons

enum ToastType {
    case success(String, actionName: String? = nil)
    case error(String)
    case info(String)

    var message: String {
        switch self {
        case .success(let msg, _), .error(let msg), .info(let msg): return msg
        }
    }

    var actionName: String? {
        switch self {
        case .success(_, let name): return name
        default: return nil
        }
    }

    var dismissDelay: TimeInterval {
        switch self {
        case .success: return Constants.Defaults.toastSuccessDismiss
        case .error, .info: return Constants.Defaults.toastErrorDismiss
        }
    }

    var icon: AppIcon {
        switch self {
        case .success: return .success
        case .error: return .error
        case .info: return .info
        }
    }

    var iconColor: Color {
        switch self {
        case .success: return Theme.Colors.statusGreen
        case .error: return Theme.Colors.statusRed
        case .info: return Theme.Colors.textTertiary
        }
    }

    /// Leading accent bar color — asymmetric wabi-sabi mark
    var accentColor: Color {
        switch self {
        case .success: return Theme.Colors.statusGreen
        case .error: return Theme.Colors.statusRed
        case .info: return Theme.Colors.textTertiary
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
        HStack(spacing: 0) {
            // Leading ink accent — an asymmetric mark, beauty in imperfection
            RoundedRectangle(cornerRadius: 1)
                .fill(toast.accentColor.opacity(0.6))
                .frame(width: 2)
                .padding(.vertical, Theme.Spacing.sm)

            HStack(spacing: Theme.Spacing.md) {
                toast.icon.image()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(toast.iconColor.opacity(0.7))

                VStack(alignment: .leading, spacing: 2) {
                    if let actionName = toast.actionName {
                        Text(actionName)
                            .font(Theme.Typography.label(10))
                            .foregroundColor(Theme.Colors.textTertiary)
                            .lineLimit(1)
                    }

                    Text(toast.message)
                        .font(Theme.Typography.body(11.5))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm + 2)
        }
        .background(Theme.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.md)
                .stroke(Theme.Colors.cardBorder, lineWidth: 1)
        )
        .shadow(color: Color(hex: "2F3430").opacity(0.04), radius: 12, y: 3)
    }
}
