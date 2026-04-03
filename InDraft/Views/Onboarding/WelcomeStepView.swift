import SwiftUI

struct WelcomeStepView: View {
    var onGetStarted: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            Image(systemName: "arrow.up")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(Theme.Colors.textPrimary)

            Text("Rewrite anything,\nanywhere.")
                .font(Theme.Typography.headline(28))
                .multilineTextAlignment(.center)
                .foregroundColor(Theme.Colors.textPrimary)

            Text("InDraft transforms selected text with AI — right\nwhere you're writing. No app switching. No copy-\npaste. One keystroke.")
                .font(Theme.Typography.body())
                .multilineTextAlignment(.center)
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(4)
                .padding(.top, Theme.Spacing.xs)

            Button("Get Started") {
                onGetStarted()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, Theme.Spacing.lg)

            Text("Takes about 2 minutes to set up")
                .font(Theme.Typography.caption())
                .foregroundColor(Theme.Colors.textTertiary)

            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.xxl)
    }
}
