import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @AppStorage(Constants.UserDefaultsKeys.onboardingStep) private var currentStep = 0
    @AppStorage(Constants.UserDefaultsKeys.onboardingComplete) private var onboardingComplete = false

    @Environment(\.modelContext) private var modelContext

    @State private var providerDisplayName = "OpenAI"
    @State private var providerBaseURL = ""
    @State private var providerAPIKey = ""
    @State private var providerModel = "gpt-4o"
    @State private var canContinue = false
    @State private var providerConfigured = false
    @State private var navigationDirection: NavigationDirection = .forward

    private let totalSteps = 5
    private let skippableSteps: Set<Int> = [2, 3, 4]

    private enum NavigationDirection {
        case forward, backward
    }

    private var providerFieldsFilled: Bool {
        !providerDisplayName.trimmingCharacters(in: .whitespaces).isEmpty
            && !providerBaseURL.trimmingCharacters(in: .whitespaces).isEmpty
            && !providerAPIKey.trimmingCharacters(in: .whitespaces).isEmpty
            && !providerModel.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header: step indicator dots + step counter
            if currentStep > 0 && currentStep <= totalSteps {
                VStack(spacing: Theme.Spacing.sm) {
                    StepIndicatorView(currentStep: currentStep, totalSteps: totalSteps + 1)

                    Text("STEP \(currentStep) OF \(totalSteps)")
                        .font(Theme.Typography.allCaps())
                        .foregroundColor(Theme.Colors.textTertiary)
                        .tracking(1.5)
                }
                .padding(.top, Theme.Spacing.xl)
            } else {
                Spacer().frame(height: Theme.Spacing.xl)
            }

            // Content with animated transitions
            ZStack {
                stepContent
                    .id(currentStep)
                    .transition(stepTransition)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(Theme.Motion.gentle, value: currentStep)

            // Navigation bar
            if currentStep > 0 && currentStep <= totalSteps {
                HStack {
                    Button("BACK") {
                        goBack()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .font(Theme.Typography.allCaps())
                    .foregroundColor(Theme.Colors.textSecondary)

                    Spacer()

                    if skippableSteps.contains(currentStep) {
                        Button("SKIP") {
                            goForward(isSkip: true)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .font(Theme.Typography.allCaps())
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding(.trailing, Theme.Spacing.md)
                    }

                    Button(currentStep == totalSteps ? "FINISH" : "CONTINUE") {
                        goForward(isSkip: false)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .font(Theme.Typography.allCaps())
                    .foregroundColor(canContinue ? Theme.Colors.textPrimary : Theme.Colors.textTertiary)
                    .disabled(!canContinue)
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .frame(width: 500, height: 450)
        .background(Theme.Colors.background)
        .onChange(of: currentStep) { _, newValue in
            switch newValue {
            case 1:
                canContinue = false
            default:
                canContinue = true
            }
        }
    }

    private var stepTransition: AnyTransition {
        switch navigationDirection {
        case .forward:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        case .backward:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0:
            WelcomeStepView(onGetStarted: { goForwardFromWelcome() })
        case 1:
            AccessibilityStepView(canContinue: $canContinue)
        case 2:
            AddProviderStepView(
                displayName: $providerDisplayName,
                baseURL: $providerBaseURL,
                apiKey: $providerAPIKey,
                model: $providerModel
            )
        case 3:
            DefaultActionsStepView()
        case 4:
            SampleTransformStepView(
                baseURL: providerBaseURL,
                apiKey: providerAPIKey,
                model: providerModel
            )
        default:
            CompleteStepView(
                onFinish: { finishOnboarding() },
                providerConfigured: providerConfigured
            )
        }
    }

    private func goForwardFromWelcome() {
        navigationDirection = .forward
        currentStep = 1
    }

    private func goBack() {
        if currentStep > 1 {
            navigationDirection = .backward
            currentStep -= 1
        }
    }

    private func goForward(isSkip: Bool) {
        // Save provider only on Continue with filled fields (not on Skip)
        if currentStep == 2 && !isSkip && providerFieldsFilled {
            saveProvider()
            providerConfigured = true
        }

        navigationDirection = .forward
        if currentStep < totalSteps {
            currentStep += 1
        } else {
            finishOnboarding()
        }
    }

    private func saveProvider() {
        let provider = Provider(
            displayName: providerDisplayName,
            baseURL: providerBaseURL,
            apiKeyReference: "provider-\(UUID().uuidString)",
            defaultModel: providerModel,
            isActive: true
        )
        modelContext.insert(provider)

        let keychain = LiveKeychainService()
        try? keychain.store(apiKey: providerAPIKey, forReference: provider.apiKeyReference)

        let actions = [
            Constants.DefaultActions.rewriteForClarity,
            Constants.DefaultActions.grammarFix,
            Constants.DefaultActions.paraphrase
        ]
        for (index, def) in actions.enumerated() {
            let action = Action(
                name: def.name,
                prompt: def.prompt,
                hotkeyKeyCode: def.keyCode,
                hotkeyModifiers: def.modifiers,
                sortOrder: index
            )
            modelContext.insert(action)
        }

        try? modelContext.save()
    }

    private func finishOnboarding() {
        onboardingComplete = true
        currentStep = totalSteps + 1
        OnboardingWindowController.shared.close()
    }
}
