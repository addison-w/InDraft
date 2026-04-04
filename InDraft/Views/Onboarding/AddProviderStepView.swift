import SwiftUI

struct AddProviderStepView: View {
    @Binding var displayName: String
    @Binding var baseURL: String
    @Binding var apiKey: String
    @Binding var model: String

    @State private var showAPIKey = false

    // Inline test connection state
    @State private var testState: TestState = .idle
    @State private var testErrorMessage: String?
    @State private var testLatencyMs: Int?

    private enum TestState {
        case idle, testing, success, failure
    }

    private var allFieldsFilled: Bool {
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty
            && !baseURL.trimmingCharacters(in: .whitespaces).isEmpty
            && !apiKey.trimmingCharacters(in: .whitespaces).isEmpty
            && !model.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("Connect your AI provider")
                    .font(Theme.Typography.pageTitle(22))
                    .foregroundColor(Theme.Colors.textPrimary)

                Text("InDraft works with any OpenAI-compatible API. Bring your own key.")
                    .font(Theme.Typography.body())
                    .foregroundColor(Theme.Colors.textSecondary)
            }

            // Form fields
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                fieldGroup(label: "DISPLAY NAME") {
                    TextField("OpenAI", text: $displayName)
                        .inputFieldStyle()
                }

                fieldGroup(label: "BASE URL") {
                    TextField("https://api.openai.com/v1", text: $baseURL)
                        .inputFieldStyle()
                }

                fieldGroup(label: "API KEY") {
                    HStack(spacing: Theme.Spacing.sm) {
                        Group {
                            if showAPIKey {
                                TextField("sk-...", text: $apiKey)
                            } else {
                                SecureField("sk-...", text: $apiKey)
                            }
                        }
                        .inputFieldStyle()

                        Button(showAPIKey ? "HIDE" : "SHOW") {
                            showAPIKey.toggle()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .font(Theme.Typography.label())
                        .foregroundColor(Theme.Colors.textTertiary)
                    }
                }

                fieldGroup(label: "DEFAULT MODEL") {
                    TextField("gpt-4o", text: $model)
                        .inputFieldStyle()
                }
            }

            // Inline test connection (visible only when all fields filled)
            if allFieldsFilled {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    HStack(spacing: Theme.Spacing.md) {
                        Button("TEST CONNECTION") {
                            runTest()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(testState == .testing)

                        // Inline result
                        switch testState {
                        case .idle:
                            EmptyView()
                        case .testing:
                            HStack(spacing: Theme.Spacing.xs) {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Testing...")
                                    .font(Theme.Typography.caption())
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                        case .success:
                            HStack(spacing: Theme.Spacing.xs) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Theme.Colors.statusGreen)
                                    .font(.system(size: 14))
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Connected")
                                        .font(Theme.Typography.caption())
                                        .foregroundColor(Theme.Colors.statusGreen)
                                    if let ms = testLatencyMs {
                                        Text("\(ms)ms")
                                            .font(Theme.Typography.caption())
                                            .foregroundColor(Theme.Colors.textTertiary)
                                    }
                                }
                            }
                        case .failure:
                            HStack(spacing: Theme.Spacing.xs) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Theme.Colors.statusRed)
                                    .font(.system(size: 14))
                                Text(testErrorMessage ?? "Failed")
                                    .font(Theme.Typography.caption())
                                    .foregroundColor(Theme.Colors.statusRed)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .transition(.opacity.animation(Theme.Motion.quick))
            }

            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.top, Theme.Spacing.lg)
    }

    @ViewBuilder
    private func fieldGroup(label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(label)
                .font(Theme.Typography.allCaps())
                .foregroundColor(Theme.Colors.textTertiary)
                .tracking(1.2)

            content()
        }
    }

    private func runTest() {
        testState = .testing
        testErrorMessage = nil

        Task {
            let service = LiveProviderService()
            let result = await service.testConnection(
                baseURL: baseURL,
                apiKey: apiKey,
                model: model
            )

            await MainActor.run {
                switch result {
                case .success(_, let ms):
                    testState = .success
                    testLatencyMs = ms
                case .failure(let message):
                    testState = .failure
                    testErrorMessage = message
                }
            }
        }
    }
}
