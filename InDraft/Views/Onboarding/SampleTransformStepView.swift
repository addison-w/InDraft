import SwiftUI
import Hugeicons

struct SampleTransformStepView: View {
    let baseURL: String
    let apiKey: String
    let model: String

    @State private var sampleText = "The meeting was really good and we talked about a lot of important things that need to be done soon."
    @State private var isTransforming = false
    @State private var hasTransformed = false

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            WabiSabiSparkIllustration()

            VStack(spacing: Theme.Spacing.md) {
                Text("Try a transformation")
                    .font(Theme.Typography.pageTitle(22))
                    .foregroundColor(Theme.Colors.textPrimary)

                Text("See InDraft in action. Edit the text below,\nthen transform it.")
                    .font(Theme.Typography.body())
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("SAMPLE TEXT")
                    .font(Theme.Typography.allCaps())
                    .foregroundColor(Theme.Colors.textTertiary)
                    .tracking(1.2)

                TextEditor(text: $sampleText)
                    .font(Theme.Typography.body())
                    .foregroundColor(Theme.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(Theme.Spacing.md)
                    .frame(minHeight: 80)
                    .background(Theme.Colors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            }
            .frame(maxWidth: Theme.OnboardingLayout.contentMaxWidth)

            HStack {
                Button(action: runTransform) {
                    HStack(spacing: Theme.Spacing.sm) {
                        if isTransforming {
                            ProgressView()
                                .controlSize(.small)
                        }
                        Text(isTransforming ? "Transforming..." : "Rewrite for Clarity")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isTransforming || sampleText.trimmingCharacters(in: .whitespaces).isEmpty)

                if hasTransformed {
                    AppIcon.success.image()
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(Theme.Colors.statusGreen)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Theme.Spacing.xl)
    }

    private func runTransform() {
        isTransforming = true
        Task {
            let service = LiveProviderService()
            do {
                let transformed = try await service.transform(
                    text: sampleText,
                    prompt: Constants.DefaultActions.rewriteForClarity.prompt,
                    baseURL: baseURL,
                    apiKey: apiKey,
                    model: model
                )
                await MainActor.run {
                    sampleText = transformed
                    hasTransformed = true
                    isTransforming = false
                }
            } catch {
                await MainActor.run {
                    isTransforming = false
                }
            }
        }
    }
}
