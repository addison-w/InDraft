import Cocoa
import SwiftData

enum OutputBehavior: String, Codable, CaseIterable {
    case replace
    case preview
    case clipboard
}

@Model
final class Action {
    @Attribute(.unique) var id: UUID
    var name: String
    var prompt: String
    var hotkeyKeyCode: UInt32?
    var hotkeyModifiers: UInt32?
    var outputBehavior: OutputBehavior
    var enabled: Bool
    var sortOrder: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        prompt: String,
        hotkeyKeyCode: UInt32? = nil,
        hotkeyModifiers: UInt32? = nil,
        outputBehavior: OutputBehavior = .replace,
        enabled: Bool = true,
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.prompt = prompt
        self.hotkeyKeyCode = hotkeyKeyCode
        self.hotkeyModifiers = hotkeyModifiers
        self.outputBehavior = outputBehavior
        self.enabled = enabled
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var hasHotkey: Bool {
        hotkeyKeyCode != nil
    }

    var hotkeyDisplayString: String {
        guard let keyCode = hotkeyKeyCode, let modifiers = hotkeyModifiers else {
            return ""
        }
        var parts: [String] = []
        if modifiers & UInt32(NSEvent.ModifierFlags.control.rawValue) != 0 {
            parts.append("⌃")
        }
        if modifiers & UInt32(NSEvent.ModifierFlags.option.rawValue) != 0 {
            parts.append("⌥")
        }
        if modifiers & UInt32(NSEvent.ModifierFlags.shift.rawValue) != 0 {
            parts.append("⇧")
        }
        if modifiers & UInt32(NSEvent.ModifierFlags.command.rawValue) != 0 {
            parts.append("⌘")
        }
        parts.append(KeyCodeMapping.stringForKeyCode(keyCode))
        return parts.joined()
    }
}

enum KeyCodeMapping {
    static func stringForKeyCode(_ keyCode: UInt32) -> String {
        switch Int(keyCode) {
        case 18: return "1"
        case 19: return "2"
        case 20: return "3"
        case 21: return "4"
        case 23: return "5"
        case 22: return "6"
        case 26: return "7"
        case 28: return "8"
        case 25: return "9"
        case 29: return "0"
        default: return "?"
        }
    }
}
