import AppKit
import SwiftUI

final class PreviewPanelController {
    private var panel: NSPanel?

    func show(
        original: String,
        transformed: String,
        onAccept: @escaping () -> Void,
        onReject: @escaping () -> Void,
        onCopy: @escaping () -> Void
    ) {
        dismiss()

        let view = PreviewPanelView(
            originalText: original,
            transformedText: transformed,
            onAccept: { [weak self] in
                onAccept()
                self?.dismiss()
            },
            onReject: { [weak self] in
                onReject()
                self?.dismiss()
            },
            onCopy: { [weak self] in
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(transformed, forType: .string)
                onCopy()
                self?.dismiss()
            }
        )

        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = NSRect(x: 0, y: 0, width: 450, height: 300)

        let styleMask: NSWindow.StyleMask = [
            .titled,
            .closable,
            .nonactivatingPanel
        ]

        let newPanel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 300),
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )

        newPanel.contentView = hostingView
        newPanel.level = .floating
        newPanel.isFloatingPanel = true
        newPanel.hidesOnDeactivate = false
        newPanel.titleVisibility = .hidden
        newPanel.titlebarAppearsTransparent = true
        newPanel.isMovableByWindowBackground = true
        newPanel.backgroundColor = .clear
        newPanel.isOpaque = false
        newPanel.hasShadow = false
        newPanel.center()

        newPanel.orderFrontRegardless()
        panel = newPanel
    }

    func dismiss() {
        panel?.close()
        panel = nil
    }
}
