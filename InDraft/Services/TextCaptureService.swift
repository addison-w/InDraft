import AppKit
import ApplicationServices

// MARK: - Protocol

protocol TextCaptureServiceProtocol {
    /// Capture the currently selected text from the frontmost application.
    func captureSelectedText() async throws -> String
}

// MARK: - Errors

enum CaptureError: Error, Equatable {
    case noTextSelected
    case captureFailedAX
    case captureFailedClipboard
    case bothFailed
}

// MARK: - Live Implementation

final class LiveTextCaptureService: TextCaptureServiceProtocol {

    /// 500ms timeout for accessibility capture.
    private let axTimeoutNanoseconds: UInt64 = 500_000_000

    func captureSelectedText() async throws -> String {
        // Strategy 1: Accessibility API
        if let text = try? await captureViaAccessibility() {
            guard !text.isEmpty else { throw CaptureError.noTextSelected }
            return text
        }

        // Strategy 2: Clipboard fallback
        if let text = try? await captureViaClipboard() {
            guard !text.isEmpty else { throw CaptureError.noTextSelected }
            return text
        }

        throw CaptureError.bothFailed
    }

    // MARK: - Strategy 1: Accessibility API

    /// Use AXUIElement to read the selected text attribute from the focused element.
    func captureViaAccessibility() async throws -> String {
        try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask {
                let result = self.readSelectedTextViaAX()
                guard let text = result else {
                    throw CaptureError.captureFailedAX
                }
                return text
            }

            group.addTask {
                try await Task.sleep(nanoseconds: self.axTimeoutNanoseconds)
                throw CaptureError.captureFailedAX
            }

            // Return the first successful result; the timeout task throws so it
            // only "wins" if the AX task hasn't finished.
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }

    private func readSelectedTextViaAX() -> String? {
        let systemWide = AXUIElementCreateSystemWide()

        // Get the focused application.
        var focusedAppValue: AnyObject?
        let appResult = AXUIElementCopyAttributeValue(
            systemWide,
            kAXFocusedApplicationAttribute as CFString,
            &focusedAppValue
        )
        guard appResult == .success,
              let focusedApp = focusedAppValue else {
            return nil
        }
        // swiftlint:disable:next force_cast
        let appElement = focusedApp as! AXUIElement

        // Get the focused UI element within the application.
        var focusedElementValue: AnyObject?
        let elementResult = AXUIElementCopyAttributeValue(
            appElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElementValue
        )
        guard elementResult == .success,
              let focusedElement = focusedElementValue else {
            return nil
        }
        // swiftlint:disable:next force_cast
        let element = focusedElement as! AXUIElement

        // Read the selected text attribute.
        var selectedTextValue: AnyObject?
        let textResult = AXUIElementCopyAttributeValue(
            element,
            kAXSelectedTextAttribute as CFString,
            &selectedTextValue
        )
        guard textResult == .success,
              let selectedText = selectedTextValue as? String else {
            return nil
        }

        return selectedText
    }

    // MARK: - Strategy 2: Clipboard Fallback

    /// Save the clipboard, simulate Cmd+C, read the result, then restore.
    func captureViaClipboard() async throws -> String {
        let pasteboard = NSPasteboard.general
        let savedContents = saveClipboard(pasteboard)

        defer {
            restoreClipboard(pasteboard, contents: savedContents)
        }

        // Clear the clipboard so we can detect new content.
        pasteboard.clearContents()

        // Simulate Cmd+C.
        simulateCmdC()

        // Brief delay for the target app to process the copy command.
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms

        guard let copiedText = pasteboard.string(forType: .string) else {
            throw CaptureError.captureFailedClipboard
        }

        return copiedText
    }

    // MARK: - Clipboard Helpers

    private func saveClipboard(_ pasteboard: NSPasteboard) -> [NSPasteboardItem] {
        return pasteboard.pasteboardItems?.map { item in
            let newItem = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    newItem.setData(data, forType: type)
                }
            }
            return newItem
        } ?? []
    }

    private func restoreClipboard(_ pasteboard: NSPasteboard, contents: [NSPasteboardItem]) {
        pasteboard.clearContents()
        if !contents.isEmpty {
            pasteboard.writeObjects(contents)
        }
    }

    private func simulateCmdC() {
        let source = CGEventSource(stateID: .hidSystemState)

        // Key down: C (keycode 8) with Cmd modifier
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)

        // Key up
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        keyUp?.flags = .maskCommand
        keyUp?.post(tap: .cghidEventTap)
    }
}

// MARK: - Mock Implementation

final class MockTextCaptureService: TextCaptureServiceProtocol {
    var resultToReturn: Result<String, CaptureError> = .success("mock selected text")

    func captureSelectedText() async throws -> String {
        switch resultToReturn {
        case .success(let text):
            guard !text.isEmpty else { throw CaptureError.noTextSelected }
            return text
        case .failure(let error):
            throw error
        }
    }
}
