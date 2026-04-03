import Cocoa
import SwiftData

enum TransformError: Error {
    case noTextSelected
    case captureFailed(String)
    case providerFailed(String)
    case replaceFailed(String)
    case noActiveProvider
    case actionDisabled
}

enum TransformResult {
    case replaced
    case fallbackClipboard
    case copiedToClipboard
    case previewing(original: String, transformed: String)
}

protocol TransformServiceProtocol {
    func execute(action: Action, provider: Provider, apiKey: String) async -> (TransformResult?, TransformError?)
}

actor LiveTransformService: TransformServiceProtocol {
    private let captureService: TextCaptureServiceProtocol
    private let replaceService: TextReplaceServiceProtocol
    private let providerService: ProviderServiceProtocol
    private let historyService: HistoryServiceProtocol?
    private let appState: AppState?

    init(
        captureService: TextCaptureServiceProtocol,
        replaceService: TextReplaceServiceProtocol,
        providerService: ProviderServiceProtocol,
        historyService: HistoryServiceProtocol? = nil,
        appState: AppState? = nil
    ) {
        self.captureService = captureService
        self.replaceService = replaceService
        self.providerService = providerService
        self.historyService = historyService
        self.appState = appState
    }

    func execute(action: Action, provider: Provider, apiKey: String) async -> (TransformResult?, TransformError?) {
        let startTime = DispatchTime.now()

        await MainActor.run { appState?.setProcessing() }

        // Get the frontmost app name
        let sourceApp = NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown"

        // Step 1: Capture selected text
        let originalText: String
        do {
            originalText = try await captureService.captureSelectedText()
        } catch let error as CaptureError {
            let errorMessage: String
            switch error {
            case .noTextSelected:
                await MainActor.run { appState?.setIdle() }
                return (nil, .noTextSelected)
            case .bothFailed:
                errorMessage = "Could not read selected text"
            default:
                errorMessage = "Text capture failed"
            }
            await MainActor.run { appState?.setError(errorMessage) }
            recordError(sourceApp: sourceApp, action: action, provider: provider, originalText: "", latencyMs: elapsedMs(from: startTime), errorCode: "capture_failed", errorMessage: errorMessage)
            return (nil, .captureFailed(errorMessage))
        } catch {
            let msg = "Text capture failed"
            await MainActor.run { appState?.setError(msg) }
            return (nil, .captureFailed(msg))
        }

        // Step 2: Send to AI provider
        let transformedText: String
        do {
            let model = action.modelOverride ?? provider.defaultModel
            transformedText = try await providerService.transform(
                text: originalText,
                prompt: action.prompt,
                baseURL: provider.baseURL,
                apiKey: apiKey,
                model: model
            )
        } catch {
            let errorMessage = error.localizedDescription
            await MainActor.run { appState?.setError(errorMessage) }
            recordError(sourceApp: sourceApp, action: action, provider: provider, originalText: originalText, latencyMs: elapsedMs(from: startTime), errorCode: "provider_failed", errorMessage: errorMessage)
            return (nil, .providerFailed(errorMessage))
        }

        let latencyMs = elapsedMs(from: startTime)

        // Step 3: Output based on action behavior
        switch action.outputBehavior {
        case .replace:
            do {
                let result = try await replaceService.replaceSelectedText(with: transformedText)
                let transformResult: TransformResult
                switch result {
                case .replaced:
                    transformResult = .replaced
                    await MainActor.run { appState?.setSuccess() }
                case .fallbackClipboard:
                    transformResult = .fallbackClipboard
                    await MainActor.run { appState?.setSuccess() }
                case .copiedToClipboard:
                    transformResult = .copiedToClipboard
                    await MainActor.run { appState?.setSuccess() }
                }
                recordSuccess(sourceApp: sourceApp, action: action, provider: provider, originalText: originalText, transformedText: transformedText, latencyMs: latencyMs)
                return (transformResult, nil)
            } catch {
                let msg = "Text replacement failed"
                await MainActor.run { appState?.setError(msg) }
                recordError(sourceApp: sourceApp, action: action, provider: provider, originalText: originalText, latencyMs: latencyMs, errorCode: "replace_failed", errorMessage: msg)
                return (nil, .replaceFailed(msg))
            }

        case .preview:
            await MainActor.run { appState?.setIdle() }
            recordSuccess(sourceApp: sourceApp, action: action, provider: provider, originalText: originalText, transformedText: transformedText, latencyMs: latencyMs)
            return (.previewing(original: originalText, transformed: transformedText), nil)

        case .clipboard:
            await MainActor.run {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(transformedText, forType: .string)
                appState?.setSuccess()
            }
            recordSuccess(sourceApp: sourceApp, action: action, provider: provider, originalText: originalText, transformedText: transformedText, latencyMs: latencyMs)
            return (.copiedToClipboard, nil)
        }
    }

    // MARK: - Helpers

    private func elapsedMs(from start: DispatchTime) -> Int {
        let end = DispatchTime.now()
        let nanos = end.uptimeNanoseconds - start.uptimeNanoseconds
        return Int(nanos / 1_000_000)
    }

    private func recordSuccess(sourceApp: String, action: Action, provider: Provider, originalText: String, transformedText: String, latencyMs: Int) {
        historyService?.recordSuccess(
            sourceApp: sourceApp,
            actionID: action.id,
            actionName: action.name,
            providerID: provider.id,
            providerName: provider.displayName,
            modelName: action.modelOverride ?? provider.defaultModel,
            originalText: originalText,
            transformedText: transformedText,
            latencyMs: latencyMs
        )
    }

    private func recordError(sourceApp: String, action: Action, provider: Provider, originalText: String, latencyMs: Int, errorCode: String, errorMessage: String) {
        historyService?.recordError(
            sourceApp: sourceApp,
            actionID: action.id,
            actionName: action.name,
            providerID: provider.id,
            providerName: provider.displayName,
            modelName: action.modelOverride ?? provider.defaultModel,
            originalText: originalText,
            latencyMs: latencyMs,
            errorCode: errorCode,
            errorMessage: errorMessage
        )
    }
}
