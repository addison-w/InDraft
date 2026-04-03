import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage(Constants.UserDefaultsKeys.launchAtLogin) private var launchAtLogin = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                Text("General")
                    .font(.system(size: 28, design: .serif))
                    .fontWeight(.medium)
                    .foregroundColor(Theme.Colors.textPrimary)

                VStack(alignment: .leading, spacing: 0) {
                    settingsRow(
                        title: "Launch at Login",
                        subtitle: "Automatically start InDraft when you log in",
                        isOn: $launchAtLogin
                    )
                    .padding(Theme.Spacing.xl)
                }
                .background(Theme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.md)
                        .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                )
                .shadow(color: Color(hex: "2F3430").opacity(0.03), radius: 8, y: 2)

                Spacer()
            }
            .padding(Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }

    private func settingsRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(Theme.Typography.body(14))
                    .foregroundColor(Theme.Colors.textPrimary)
                Text(subtitle)
                    .font(Theme.Typography.caption(11))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }
}
