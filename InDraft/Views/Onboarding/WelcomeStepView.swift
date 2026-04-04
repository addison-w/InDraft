import SwiftUI

struct WelcomeStepView: View {
    var onGetStarted: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()

            Image(nsImage: NSImage(contentsOfFile: Bundle.main.path(forResource: "quill-logo", ofType: "svg") ?? "") ?? NSImage())
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .foregroundColor(Theme.Colors.textPrimary)

            VStack(spacing: Theme.Spacing.md) {
                Text("Rewrite anything,\nanywhere.")
                    .font(Theme.Typography.pageTitle(28))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.Colors.textPrimary)

                Text("InDraft transforms selected text with AI — right\nwhere you're writing. No app switching. No copy-\npaste. One keystroke.")
                    .font(Theme.Typography.body())
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineSpacing(4)
            }

            Button("Get Started") {
                onGetStarted()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, Theme.Spacing.sm)

            Text("Takes about 2 minutes to set up")
                .font(Theme.Typography.caption())
                .foregroundColor(Theme.Colors.textTertiary)

            Spacer()
        }
        .frame(maxWidth: Theme.OnboardingLayout.contentMaxWidth)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Theme.Spacing.xxl)
    }
}
