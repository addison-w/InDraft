import SwiftUI

struct CompleteStepView: View {
    let onFinish: () -> Void
    var providerConfigured: Bool = true

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
        (
            name: Constants.DefaultActions.translateToEnglish.name,
            keyCode: Constants.DefaultActions.translateToEnglish.keyCode,
            modifiers: Constants.DefaultActions.translateToEnglish.modifiers
        ),
        (
            name: Constants.DefaultActions.professionalTone.name,
            keyCode: Constants.DefaultActions.professionalTone.keyCode,
            modifiers: Constants.DefaultActions.professionalTone.modifiers
        ),
        (
            name: Constants.DefaultActions.eli5.name,
            keyCode: Constants.DefaultActions.eli5.keyCode,
            modifiers: Constants.DefaultActions.eli5.modifiers
        ),
    ]

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            WabiSabiCheckmarkIllustration()
                .padding(.bottom, Theme.Spacing.sm)

            Text("You're all set.")
                .font(Theme.Typography.pageTitle(28))
                .foregroundColor(Theme.Colors.textPrimary)

            Text("InDraft is running in your menu bar. Select any text\nand press a hotkey to transform it.")
                .font(Theme.Typography.body())
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Hint when provider was skipped
            if !providerConfigured {
                Text("Add an AI provider in Settings to start transforming text.")
                    .font(Theme.Typography.caption())
                    .foregroundColor(Theme.Colors.statusAmber)
                    .multilineTextAlignment(.center)
            }

            // Action list with keycaps
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
                    .padding(.vertical, Theme.Spacing.sm)
                }
            }
            .cardStyle()
            .padding(.horizontal, Theme.Spacing.md)

            Spacer()
        }
        .frame(maxWidth: Theme.OnboardingLayout.contentMaxWidth + 40)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Theme.Spacing.xl)
    }
}
