import SwiftUI

struct DefaultActionsStepView: View {
    private let actions = [
        (name: Constants.DefaultActions.rewriteForClarity.name, hotkey: "\u{2303}\u{2325}1"),
        (name: Constants.DefaultActions.grammarFix.name, hotkey: "\u{2303}\u{2325}2"),
        (name: Constants.DefaultActions.paraphrase.name, hotkey: "\u{2303}\u{2325}3"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Text("Your default actions")
                .font(Theme.Typography.sectionTitle(22))
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

                        hotkeyBadge(action.hotkey)
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

    @ViewBuilder
    private func hotkeyBadge(_ hotkey: String) -> some View {
        HStack(spacing: 4) {
            ForEach(Array(hotkey), id: \.self) { char in
                Text(String(char))
                    .font(Theme.Typography.mono(12))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .frame(width: 24, height: 24)
                    .background(Theme.Colors.badgeBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
            }
        }
    }
}
