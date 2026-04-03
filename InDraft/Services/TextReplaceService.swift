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
        let clipboardSucceeded = (try? await replaceViaClipboard(text: text)) ?? false
        if clipboardSucceeded {
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

        // Verify the write actually took effect by reading back.
        var verifyValue: AnyObject?
        let verifyResult = AXUIElementCopyAttributeValue(
            element,
            kAXSelectedTextAttribute as CFString,
            &verifyValue
        )
        if verifyResult == .success, let verifyText = verifyValue as? String {
            // If we can read back and it doesn't match, the write failed silently.
            if verifyText != text {
                throw ReplaceError.replaceFailedAX
            }
        }
        // If we can't read back at all, trust the .success from the set call.
    }

    // MARK: - Strategy 2: Clipboard Fallback

    func replaceViaClipboard(text: String) async throws -> Bool {
        let pasteboard = NSPasteboard.general
        let savedContents = saveClipboard(pasteboard)

        // Place the replacement text on the clipboard.
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        // Wait for clipboard to settle before simulating paste.
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms

        // Simulate Cmd+V.
        simulateCmdV()

        // Wait for the paste to be processed by the target app.
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms

        // Schedule clipboard restoration after the delay.
        scheduleClipboardRestore(pasteboard, contents: savedContents)

        // Best-effort verification: if we can read back via AX, check the text changed.
        // If AX isn't available for reading, assume success (can't verify).
        let systemWide = AXUIElementCreateSystemWide()
        var focusedAppValue: AnyObject?
        guard AXUIElementCopyAttributeValue(systemWide, kAXFocusedApplicationAttribute as CFString, &focusedAppValue) == .success,
              let focusedApp = focusedAppValue else {
            return true // Can't verify, assume success
        }
        let appElement = focusedApp as! AXUIElement // swiftlint:disable:this force_cast
        var focusedElementValue: AnyObject?
        guard AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedElementValue) == .success,
              let focusedElement = focusedElementValue else {
            return true // Can't verify, assume success
        }
        let element = focusedElement as! AXUIElement // swiftlint:disable:this force_cast

        // Try to read the value of the focused element to see if paste worked.
        var valueRef: AnyObject?
        let valueResult = AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &valueRef)
        if valueResult == .success, let currentValue = valueRef as? String {
            // If the pasted text appears in the element's value, consider it successful.
            return currentValue.contains(text)
        }

        // Can't read back — assume paste worked (best effort).
        return true
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

        // Brief delay between key-down and key-up for reliable event processing
        Thread.sleep(forTimeInterval: 0.05) // 50ms

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
