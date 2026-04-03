import Carbon.HIToolbox

enum Constants {
    enum App {
        static let name = "InDraft"
        static let bundleIdentifier = "com.indraft.app"
    }

    enum Defaults {
        static let historyRetentionDays = 30
        static let clipboardRestoreTimeout: TimeInterval = 30
        static let clipboardCaptureTimeout: TimeInterval = 5
        static let captureTimeout: TimeInterval = 0.5
        static let connectionTestTimeout: TimeInterval = 10
        static let successDismissDelay: TimeInterval = 3
        static let errorDismissDelay: TimeInterval = 10
        static let toastSuccessDismiss: TimeInterval = 2
        static let toastErrorDismiss: TimeInterval = 5
        static let defaultBaseURL = "https://api.openai.com/v1"
    }

    enum UserDefaultsKeys {
        static let launchAtLogin = "launchAtLogin"
        static let onboardingComplete = "onboardingComplete"
        static let onboardingStep = "onboardingStep"
        static let historyRetentionDays = "historyRetentionDays"
        static let historyRecordingEnabled = "historyRecordingEnabled"
    }

    enum DefaultActions {
        static let rewriteForClarity = (
            name: "Rewrite for Clarity",
            prompt: "Rewrite the following text to be clearer and more concise. Preserve the original meaning. Return only the rewritten text, no explanations.",
            keyCode: UInt32(kVK_ANSI_1),
            modifiers: UInt32(controlKey | optionKey)
        )

        static let grammarFix = (
            name: "Grammar Fix",
            prompt: "Fix all grammar, spelling, and punctuation errors in the following text. Preserve the original meaning and tone. Return only the corrected text, no explanations.",
            keyCode: UInt32(kVK_ANSI_2),
            modifiers: UInt32(controlKey | optionKey)
        )

        static let paraphrase = (
            name: "Paraphrase",
            prompt: "Paraphrase the following text while preserving its meaning. Use different wording and sentence structure. Return only the paraphrased text, no explanations.",
            keyCode: UInt32(kVK_ANSI_3),
            modifiers: UInt32(controlKey | optionKey)
        )
    }
}
