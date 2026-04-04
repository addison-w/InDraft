import SwiftUI

/// Minimal dot pagination indicator for onboarding steps.
struct StepIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(index == currentStep ? Theme.Colors.textPrimary : Theme.Colors.divider)
                    .frame(
                        width: Theme.OnboardingLayout.dotSize,
                        height: Theme.OnboardingLayout.dotSize
                    )
                    .animation(Theme.Motion.quick, value: currentStep)
            }
        }
    }
}
