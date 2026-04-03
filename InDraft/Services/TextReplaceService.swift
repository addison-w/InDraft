import AppKit
import ApplicationServices

// MARK: - Result Type

enum ReplaceResult: Equatable {
    /// Successfully replaced via AX or clipboard simulation.
    case replaced
    /// Replaced via clipboard paste fallback (clipboard will be restored after delay).
    case fallbackClipboard
    /// Both strategies failed; the text was copied to the clipboard for manual pasting.
    case copiedToClipboard
}

// MARK: - Protocol

protocol TextReplaceServiceProtocol {
    /// Replace the currently selected text with the given string.
    func replaceSelectedText(with text: String) async throws -> ReplaceResult
}

// MARK: - Errors

enum ReplaceError: Error, Equatable {
    case replaceFailedAX
    case replaceFailedClipboard
}

// MARK: - Live Implementation

final class LiveTextReplaceService: TextReplaceServiceProtocol {

    /// How long to wait before restoring the clipboard after a paste fallback.
    private let clipboardRestoreDelay: TimeInterval = 30

    func replaceSelectedText(with text: String) async throws -> ReplaceResult {
        // Strategy 1: Accessibility API
        if (try? replaceViaAccessibility(text: text)) != nil {
            return .replaced
        }

        // Strategy 2: Clipboard fallback (simulate Cmd+V)
        if (try? await replaceViaClipboard(text: text)) != nil {
            return .fallbackClipboard
        }

        // Last resort: copy the result to the clipboard for manual pasting.
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        return .copiedToClipboard
    }

    // MARK: - Strategy 1: Accessibility API

    func replaceViaAccessibility(text: String) throws {
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
            throw ReplaceError.replaceFailedAX
        }
        // swiftlint:disable:next force_cast
        let appElement = focusedApp as! AXUIElement

        // Get the focused UI element.
        var focusedElementValue: AnyObject?
        let elementResult = AXUIElementCopyAttributeValue(
            appElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElementValue
        )
        guard elementResult == .success,
              let focusedElement = focusedElementValue else {
            throw ReplaceError.replaceFailedAX
        }
        // swiftlint:disable:next force_cast
        let element = focusedElement as! AXUIElement

        // Set the selected text attribute.
        let setResult = AXUIElementSetAttributeValue(
            element,
            kAXSelectedTextAttribute as CFString,
            text as CFTypeRef
        )
        guard setResult == .success else {
            throw ReplaceError.replaceFailedAX
        }
    }

    // MARK: - Strategy 2: Clipboard Fallback

    func replaceViaClipboard(text: String) async throws {
        let pasteboard = NSPasteboard.general
        let savedContents = saveClipboard(pasteboard)

        // Place the replacement text on the clipboard.
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        // Simulate Cmd+V.
        simulateCmdV()

        // Brief delay for the paste to be processed.
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms

        // Schedule clipboard restoration after the delay.
        scheduleClipboardRestore(pasteboard, contents: savedContents)
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

    private func scheduleClipboardRestore(_ pasteboard: NSPasteboard, contents: [NSPasteboardItem]) {
        let delay = clipboardRestoreDelay
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            pasteboard.clearContents()
            if !contents.isEmpty {
                pasteboard.writeObjects(contents)
            }
        }
    }

    private func simulateCmdV() {
        let source = CGEventSource(stateID: .hidSystemState)

        // Key down: V (keycode 9) with Cmd modifier
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)

        // Key up
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyUp?.flags = .maskCommand
        keyUp?.post(tap: .cghidEventTap)
    }
}

// MARK: - Mock Implementation

final class MockTextReplaceService: TextReplaceServiceProtocol {
    var resultToReturn: ReplaceResult = .replaced

    func replaceSelectedText(with text: String) async throws -> ReplaceResult {
        return resultToReturn
    }
}
