import SwiftUI
import ApplicationServices

struct AccessibilityStepView: View {
    @Binding var canContinue: Bool
    @State private var isGranted = false
    @State private var timer: Timer?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Text("InDraft needs Accessibility access")
                .font(Theme.Typography.pageTitle(22))
                .foregroundColor(Theme.Colors.textPrimary)

            Text("This permission lets InDraft read your selected text and replace it with the transformed result. Your text never leaves your device except to your chosen AI provider.")
                .font(Theme.Typography.body())
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            // Instructions card
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("INSTRUCTIONS")
                    .font(Theme.Typography.allCaps())
                    .foregroundColor(Theme.Colors.textTertiary)
                    .tracking(1.2)

                // Breadcrumb navigation path
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "gear")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Colors.textSecondary)

                    Text("System Settings")
                        .font(Theme.Typography.caption())
                        .foregroundColor(Theme.Colors.textTertiary)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 8))
                        .foregroundColor(Theme.Colors.textTertiary)

                    Text("Privacy & Security")
                        .font(Theme.Typography.caption())
                        .foregroundColor(Theme.Colors.textTertiary)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 8))
                        .foregroundColor(Theme.Colors.textTertiary)

                    Text("Accessibility")
                        .font(Theme.Typography.caption())
                        .foregroundColor(Theme.Colors.textTertiary)
                }

                // Permission status
                HStack(spacing: Theme.Spacing.sm) {
                    Circle()
                        .fill(isGranted ? Theme.Colors.statusGreen : Theme.Colors.statusRed)
                        .frame(width: 8, height: 8)

                    Text(isGranted ? "GRANTED" : "NOT GRANTED")
                        .font(Theme.Typography.allCaps())
                        .foregroundColor(isGranted ? Theme.Colors.statusGreen : Theme.Colors.statusRed)
                        .tracking(1.0)
                }
                .padding(.top, Theme.Spacing.sm)
            }
            .padding(Theme.Spacing.lg)
            .cardStyle()

            if !isGranted {
                Button("Open System Settings") {
                    openAccessibilitySettings()
                }
                .buttonStyle(SecondaryButtonStyle())
            }

            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.top, Theme.Spacing.lg)
        .onAppear {
            checkPermission()
            startPolling()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private func checkPermission() {
        isGranted = AXIsProcessTrusted()
        canContinue = isGranted
    }

    private func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                checkPermission()
            }
        }
    }

    private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}
