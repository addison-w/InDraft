import SwiftUI

struct DefaultActionsStepView: View {
    private let actions = [
        (
            name: Constants.DefaultActions.grammarFix.name,
            keyCode: Constants.DefaultActions.grammarFix.keyCode,
            modifiers: Constants.DefaultActions.grammarFix.modifiers
        ),
        (
            name: Constants.DefaultActions.rewriteForClarity.name,
            keyCode: Constants.DefaultActions.rewriteForClarity.keyCode,
            modifiers: Constants.DefaultActions.rewriteForClarity.modifiers
        ),
        (
            name: Constants.DefaultActions.shorten.name,
            keyCode: Constants.DefaultActions.shorten.keyCode,
            modifiers: Constants.DefaultActions.shorten.modifiers
        ),
    ]

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            WabiSabiArrowIllustration()

            VStack(spacing: Theme.Spacing.md) {
                Text("Your default actions")
                    .font(Theme.Typography.pageTitle(22))
                    .foregroundColor(Theme.Colors.textPrimary)

                Text("InDraft comes with three built-in actions.\nYou can customize these later in Settings.")
                    .font(Theme.Typography.body())
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            VStack(spacing: 0) {
                ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                    if index > 0 {
                        Divider().foregroundColor(Theme.Colors.divider)
                    }

                    HStack {
                        Text(action.name.uppercased())
                            .font(Theme.Typography.allCaps())
                            .foregroundColor(Theme.Colors.textPrimary)
                            .tracking(1.0)

                        Spacer()

                        KeycapRow(
                            keyCode: action.keyCode,
                            modifiers: action.modifiers,
                            size: 11
                        )
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.vertical, Theme.Spacing.md)
                }
            }
            .cardStyle()
            .frame(maxWidth: Theme.OnboardingLayout.contentMaxWidth)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Theme.Spacing.xl)
    }
}
