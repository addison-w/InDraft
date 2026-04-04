import SwiftUI

struct DefaultActionsStepView: View {
    private let actions = [
        (
            name: Constants.DefaultActions.rewriteForClarity.name,
            keyCode: Constants.DefaultActions.rewriteForClarity.keyCode,
            modifiers: Constants.DefaultActions.rewriteForClarity.modifiers
        ),
        (
            name: Constants.DefaultActions.grammarFix.name,
            keyCode: Constants.DefaultActions.grammarFix.keyCode,
            modifiers: Constants.DefaultActions.grammarFix.modifiers
        ),
        (
            name: Constants.DefaultActions.paraphrase.name,
            keyCode: Constants.DefaultActions.paraphrase.keyCode,
            modifiers: Constants.DefaultActions.paraphrase.modifiers
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Text("Your default actions")
                .font(Theme.Typography.pageTitle(22))
                .foregroundColor(Theme.Colors.textPrimary)

            Text("InDraft comes with three built-in actions. You can customize these later in Settings.")
                .font(Theme.Typography.body())
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(4)

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

            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.top, Theme.Spacing.lg)
    }
}
