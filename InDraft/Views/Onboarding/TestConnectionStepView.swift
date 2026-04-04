import SwiftUI

struct TestConnectionStepView: View {
    let baseURL: String
    let apiKey: String
    let model: String
    @Binding var canContinue: Bool

    @State private var testState: TestState = .idle
    @State private var errorMessage: String?
    @State private var latencyMs: Int?

    private enum TestState {
        case idle
        case testing
        case success
        case failure
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            Text("Test your connection")
                .font(Theme.Typography.pageTitle(22))
                .foregroundColor(Theme.Colors.textPrimary)

            Text("Verify that InDraft can reach your provider and the model responds.")
                .font(Theme.Typography.body())
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            // Status display
            Group {
                switch testState {
                case .idle:
                    EmptyView()

                case .testing:
                    HStack(spacing: Theme.Spacing.sm) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Testing connection...")
                            .font(Theme.Typography.body())
                            .foregroundColor(Theme.Colors.textSecondary)
                    }

                case .success:
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.Colors.statusGreen)
                            .font(.system(size: 18))
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Connected — model responded")
                                .font(Theme.Typography.body())
                                .foregroundColor(Theme.Colors.statusGreen)
                            if let ms = latencyMs {
                                Text("\(ms)ms latency")
                                    .font(Theme.Typography.caption())
                                    .foregroundColor(Theme.Colors.textTertiary)
                            }
                        }
                    }

                case .failure:
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.Colors.statusRed)
                            .font(.system(size: 18))
                        Text(errorMessage ?? "Connection failed")
                            .font(Theme.Typography.body())
                            .foregroundColor(Theme.Colors.statusRed)
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.md)

            Button("TEST CONNECTION") {
                runTest()
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(testState == .testing)

            Spacer()
        }
        .frame(maxWidth: Theme.OnboardingLayout.contentMaxWidth)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Theme.Spacing.xl)
    }

    private func runTest() {
        testState = .testing
        canContinue = false
        errorMessage = nil

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
                    latencyMs = ms
                    canContinue = true
                case .failure(let message):
                    testState = .failure
                    errorMessage = message
                    canContinue = false
                }
            }
        }
    }
}
