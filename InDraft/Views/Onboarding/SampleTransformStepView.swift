import SwiftUI

struct SampleTransformStepView: View {
    let baseURL: String
    let apiKey: String
    let model: String

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text("Sample Transform")
                .font(Theme.Typography.pageTitle())
                .foregroundColor(Theme.Colors.textPrimary)

            Text("Try a sample transformation to see InDraft in action.")
                .font(Theme.Typography.body())
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Theme.Spacing.xl)
    }
}
