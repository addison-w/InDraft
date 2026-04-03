import SwiftUI

struct HotkeyRecorderView: View {
    @Binding var keyCode: UInt32?
    @Binding var modifiers: UInt32?

    @State private var isRecording = false
    @State private var localMonitor: Any?

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Text(displayString)
                .font(Theme.Typography.mono(11))
                .foregroundColor(isRecording ? Theme.Colors.textTertiary : Theme.Colors.textPrimary)
                .frame(minWidth: 80)
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xs + 1)
                .background(Theme.Colors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.sm)
                        .stroke(isRecording ? Theme.Colors.textTertiary : Theme.Colors.divider, lineWidth: 1)
                )

            if isRecording {
                Button {
                    stopRecording()
                } label: {
                    Text("Cancel")
                        .font(Theme.Typography.caption(11))
                        .foregroundColor(Theme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    startRecording()
                } label: {
                    Text("Record")
                        .font(Theme.Typography.caption(11))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .buttonStyle(.plain)

                if keyCode != nil {
                    Button {
                        keyCode = nil
                        modifiers = nil
                    } label: {
                        Text("Clear")
                            .font(Theme.Typography.caption(11))
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Display

    private var displayString: String {
        if isRecording {
            return "Press a key..."
        }
        guard let kc = keyCode, let mods = modifiers else {
            return "Not Set"
        }
        return Self.formatHotkey(keyCode: kc, modifiers: mods)
    }

    static func formatHotkey(keyCode: UInt32, modifiers: UInt32) -> String {
        var parts: [String] = []
        if modifiers & UInt32(NSEvent.ModifierFlags.control.rawValue) != 0 {
            parts.append("\u{2303}")
        }
        if modifiers & UInt32(NSEvent.ModifierFlags.option.rawValue) != 0 {
            parts.append("\u{2325}")
        }
        if modifiers & UInt32(NSEvent.ModifierFlags.shift.rawValue) != 0 {
            parts.append("\u{21E7}")
        }
        if modifiers & UInt32(NSEvent.ModifierFlags.command.rawValue) != 0 {
            parts.append("\u{2318}")
        }
        parts.append(KeyCodeMapping.stringForKeyCode(keyCode))
        return parts.joined(separator: " ")
    }

    // MARK: - Recording

    private func startRecording() {
        isRecording = true
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            // Require at least one modifier key
            guard !mods.isEmpty else {
                // Escape cancels recording
                if event.keyCode == 53 {
                    stopRecording()
                }
                return nil
            }
            keyCode = UInt32(event.keyCode)
            modifiers = UInt32(mods.rawValue)
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }
}
