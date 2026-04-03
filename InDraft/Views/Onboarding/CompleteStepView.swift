import SwiftUI

struct CompleteStepView: View {
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text("You're All Set")
                .font(Theme.Typography.pageTitle())
                .foregroundColor(Theme.Colors.textPrimary)

            Text("InDraft is ready to use. Access it from the menu bar.")
                .font(Theme.Typography.body())
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Button("Get Started") {
                onFinish()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, Theme.Spacing.md)
        }
        .padding(Theme.Spacing.xl)
    }
}
