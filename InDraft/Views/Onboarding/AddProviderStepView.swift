import SwiftUI

struct AddProviderStepView: View {
    @Binding var displayName: String
    @Binding var baseURL: String
    @Binding var apiKey: String
    @Binding var model: String
    @Binding var canContinue: Bool

    @State private var showAPIKey = false

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Text("Connect your AI provider")
                .font(Theme.Typography.sectionTitle(22))
                .foregroundColor(Theme.Colors.textPrimary)

            Text("InDraft works with any OpenAI-compatible API. Bring your own key.")
                .font(Theme.Typography.body())
                .foregroundColor(Theme.Colors.textSecondary)

            // Form
            VStack(spacing: 0) {
                formField(label: "DISPLAY NAME") {
                    TextField("OpenAI", text: $displayName)
                        .textFieldStyle(.plain)
                        .font(Theme.Typography.body())
                }

                Divider().foregroundColor(Theme.Colors.divider)

                formField(label: "BASE URL") {
                    TextField("https://api.openai.com/v1", text: $baseURL)
                        .textFieldStyle(.plain)
                        .font(Theme.Typography.body())
                }

                Divider().foregroundColor(Theme.Colors.divider)

                formField(label: "API KEY") {
                    HStack {
                        if showAPIKey {
                            TextField("sk-...", text: $apiKey)
                                .textFieldStyle(.plain)
                                .font(Theme.Typography.body())
                        } else {
                            SecureField("sk-...", text: $apiKey)
                                .textFieldStyle(.plain)
                                .font(Theme.Typography.body())
                        }

                        Button(showAPIKey ? "HIDE" : "SHOW") {
                            showAPIKey.toggle()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .font(Theme.Typography.allCaps())
                        .foregroundColor(Theme.Colors.textTertiary)
                    }
                }

                Divider().foregroundColor(Theme.Colors.divider)

                formField(label: "DEFAULT MODEL") {
                    TextField("gpt-4o", text: $model)
                        .textFieldStyle(.plain)
                        .font(Theme.Typography.body())
                }
            }
            .cardStyle()

            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.top, Theme.Spacing.lg)
        .onChange(of: displayName) { _, _ in validateFields() }
        .onChange(of: baseURL) { _, _ in validateFields() }
        .onChange(of: apiKey) { _, _ in validateFields() }
        .onChange(of: model) { _, _ in validateFields() }
        .onAppear { validateFields() }
    }

    @ViewBuilder
    private func formField(label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(label)
                .font(Theme.Typography.allCaps())
                .foregroundColor(Theme.Colors.textTertiary)
                .tracking(1.2)

            content()
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.md)
    }

    private func validateFields() {
        canContinue = !displayName.trimmingCharacters(in: .whitespaces).isEmpty
            && !baseURL.trimmingCharacters(in: .whitespaces).isEmpty
            && !apiKey.trimmingCharacters(in: .whitespaces).isEmpty
            && !model.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
