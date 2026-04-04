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

    private let totalSteps = 6

    var body: some View {
        VStack(spacing: 0) {
            // Step indicator (hidden on welcome and complete)
            if currentStep > 0 && currentStep < totalSteps {
                Text("STEP \(currentStep) OF \(totalSteps)")
                    .font(Theme.Typography.allCaps())
                    .foregroundColor(Theme.Colors.textTertiary)
                    .tracking(1.5)
                    .padding(.top, Theme.Spacing.xl)
            } else {
                Spacer().frame(height: Theme.Spacing.xl)
            }

            // Content
            stepContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Navigation buttons (hidden on welcome)
            if currentStep > 0 && currentStep <= totalSteps {
                HStack {
                    Button("BACK") {
                        goBack()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .font(Theme.Typography.allCaps())
                    .foregroundColor(Theme.Colors.textSecondary)

                    Spacer()

                    if currentStep == 4 || currentStep == 5 {
                        Button("SKIP") {
                            goForward()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .font(Theme.Typography.allCaps())
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding(.trailing, Theme.Spacing.md)
                    }

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
        .frame(width: 500, height: 450)
        .background(Theme.Colors.background)
        .onChange(of: currentStep) { _, newValue in
            switch newValue {
            case 1, 2, 3:
                canContinue = false
            default:
                canContinue = true
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0:
            WelcomeStepView(onGetStarted: { currentStep = 1 })
        case 1:
            AccessibilityStepView(canContinue: $canContinue)
        case 2:
            AddProviderStepView(
                displayName: $providerDisplayName,
                baseURL: $providerBaseURL,
                apiKey: $providerAPIKey,
                model: $providerModel,
                canContinue: $canContinue
            )
        case 3:
            TestConnectionStepView(
                baseURL: providerBaseURL,
                apiKey: providerAPIKey,
                model: providerModel,
                canContinue: $canContinue
            )
        case 4:
            DefaultActionsStepView()
        case 5:
            SampleTransformStepView(
                baseURL: providerBaseURL,
                apiKey: providerAPIKey,
                model: providerModel
            )
        default:
            CompleteStepView(onFinish: { finishOnboarding() })
        }
    }

    private func goBack() {
        if currentStep > 1 {
            currentStep -= 1
        }
    }

    private func goForward() {
        if currentStep == 2 {
            saveProvider()
        }
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

        if let window = NSApplication.shared.windows.first(where: {
            $0.contentView?.subviews.first != nil
        }) {
            window.close()
        }
    }
}
