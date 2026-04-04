import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @AppStorage(Constants.UserDefaultsKeys.onboardingStep) private var currentStep = 0
    @AppStorage(Constants.UserDefaultsKeys.onboardingComplete) private var onboardingComplete = false

    @Environment(\.modelContext) private var modelContext

    @State private var providerDisplayName = "OpenAI"
    @State private var providerBaseURL = ""
    @State private var providerAPIKey = ""
    @State private var providerModel = "gpt-4o-mini"
    @State private var canContinue = false
    @State private var providerConfigured = false
    @State private var providerTestSucceeded = false
    @State private var navigationDirection: NavigationDirection = .forward

    private let totalSteps = 5
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

                    Button(currentStep == totalSteps ? "FINISH" : "CONTINUE") {
                        goForward()
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
        .frame(width: 620, height: 600)
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
                model: $providerModel,
                testSucceeded: $providerTestSucceeded
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
        if currentStep > 0 {
            navigationDirection = .backward
            var prevStep = currentStep - 1
            // Skip sample transform (step 4) going back if no provider configured
            if prevStep == 4 && !providerConfigured {
                prevStep = 3
            }
            currentStep = prevStep
        }
    }

    private func goForward() {
        // Mark provider as configured if fields are filled
        if currentStep == 2 && providerFieldsFilled {
            providerConfigured = true
        }

        navigationDirection = .forward
        if currentStep < totalSteps {
            var nextStep = currentStep + 1
            // Skip sample transform (step 4) if no provider configured
            if nextStep == 4 && !providerConfigured {
                nextStep = 5
            }
            currentStep = nextStep
        } else {
            finishOnboarding()
        }
    }

    private func finishOnboarding() {
        if providerConfigured {
            // Deactivate all existing providers first
            let descriptor = FetchDescriptor<Provider>()
            if let existing = try? modelContext.fetch(descriptor) {
                for p in existing {
                    p.isActive = false
                }
            }

            let provider = Provider(
                displayName: providerDisplayName,
                baseURL: providerBaseURL,
                apiKeyReference: "provider-\(UUID().uuidString)",
                defaultModel: providerModel,
                isActive: true,
                lastTestStatus: providerTestSucceeded ? .success : .untested,
                lastTestedAt: providerTestSucceeded ? Date() : nil
            )
            modelContext.insert(provider)

            let keychain = LiveKeychainService()
            try? keychain.store(apiKey: providerAPIKey, forReference: provider.apiKeyReference)
        }

        // Create default actions if none exist
        let existingActions = (try? modelContext.fetch(FetchDescriptor<Action>())) ?? []
        if existingActions.isEmpty {
            let actions = [
                Constants.DefaultActions.grammarFix,
                Constants.DefaultActions.rewriteForClarity,
                Constants.DefaultActions.shorten
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
        }

        try? modelContext.save()

        onboardingComplete = true
        currentStep = totalSteps + 1
        OnboardingWindowController.shared.close()
    }
}
