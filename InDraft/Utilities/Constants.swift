import Carbon.HIToolbox
import Cocoa

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
        static let appearanceMode = "appearanceMode"
    }

    enum DefaultActions {
        /// NSEvent modifier flags for Control+Option — matches the encoding used by
        /// HotkeyRecorderView and expected by LiveHotkeyService.register().
        static let controlOptionModifiers = UInt32(NSEvent.ModifierFlags([.control, .option]).rawValue)

        static let grammarFix = (
            name: "Grammar Fix",
            prompt: "Fix grammar, spelling, and punctuation errors. Keep the original language, meaning, and tone intact.",
            keyCode: UInt32(kVK_ANSI_1),
            modifiers: controlOptionModifiers
        )

        static let rewriteForClarity = (
            name: "Rewrite for Clarity",
            prompt: "Rewrite for clarity. Simplify sentence structure, remove ambiguity, and keep the tone natural. Preserve the original meaning.",
            keyCode: UInt32(kVK_ANSI_2),
            modifiers: controlOptionModifiers
        )

        static let shorten = (
            name: "Shorten",
            prompt: "Shorten the text while preserving all key information and the original tone. Remove filler, redundancy, and unnecessary qualifiers.",
            keyCode: UInt32(kVK_ANSI_3),
            modifiers: controlOptionModifiers
        )

        static let translateToEnglish = (
            name: "Translate to English",
            prompt: "Translate the text to English. Preserve the original meaning, tone, and formatting. If the text is already in English, return it unchanged.",
            keyCode: UInt32(kVK_ANSI_4),
            modifiers: controlOptionModifiers
        )

        static let professionalTone = (
            name: "Professional Tone",
            prompt: "Rewrite the text in a professional, polished tone suitable for business communication. Maintain the original meaning and key points while elevating the language.",
            keyCode: UInt32(kVK_ANSI_5),
            modifiers: controlOptionModifiers
        )

        static let eli5 = (
            name: "ELI5",
            prompt: "Explain this like I'm five. Use simple words, short sentences, and relatable analogies. Make it easy to understand for anyone, regardless of background.",
            keyCode: UInt32(kVK_ANSI_6),
            modifiers: controlOptionModifiers
        )
    }
}
