import Cocoa
import SwiftUI
import Combine

/// A non-activating panel that refuses key and main window status,
/// ensuring it never steals keyboard focus from the user's active app.
private class NonActivatingPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

/// Manages a floating, non-activating NSPanel that displays toast notifications
/// near the menu bar status item. The panel never steals focus from the user's
/// active application.
@MainActor
final class ToastOverlayController {
    private var panel: NSPanel?
    private var hostingView: NSHostingView<ToastView>?
    private var cancellable: AnyCancellable?
    private weak var statusItem: NSStatusItem?
    private let toastManager: ToastManager

    init(toastManager: ToastManager, statusItem: NSStatusItem?) {
        self.toastManager = toastManager
        self.statusItem = statusItem
        observeToasts()
    }

    // MARK: - Observation

    private func observeToasts() {
        cancellable = toastManager.$currentToast
            .receive(on: RunLoop.main)
            .sink { [weak self] toast in
                if let toast = toast {
                    self?.showToast(toast)
                } else {
                    self?.hideToast()
                }
            }
    }

    // MARK: - Show / Hide

    private func showToast(_ toast: ToastType) {
        if panel == nil {
            createPanel()
        }

        guard let panel = panel, let hostingView = hostingView else { return }

        // Update the hosted view content
        hostingView.rootView = ToastView(toast: toast)

        // Size to fit content
        let fittingSize = hostingView.fittingSize
        let width = min(max(fittingSize.width, 160), 280)
        let height = fittingSize.height
        panel.setContentSize(NSSize(width: width, height: height))

        // Position below the status item
        positionPanel(panel, width: width, height: height)

        // Fade in
        panel.alphaValue = 0
        panel.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }
    }

    private func hideToast() {
        guard let panel = panel, panel.isVisible else { return }

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            self?.panel?.orderOut(nil)
        })
    }

    // MARK: - Panel Creation

    private func createPanel() {
        let panel = NonActivatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 220, height: 40),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel.level = .statusBar
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = false
        panel.hidesOnDeactivate = false

        let hostingView = NSHostingView(rootView: ToastView(toast: .info("")))
        hostingView.frame = panel.contentView?.bounds ?? .zero
        hostingView.autoresizingMask = [.width, .height]
        panel.contentView?.addSubview(hostingView)

        // Click-to-dismiss
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        panel.contentView?.addGestureRecognizer(clickGesture)

        self.panel = panel
        self.hostingView = hostingView
    }

    @objc private func handleClick() {
        toastManager.dismiss()
    }

    // MARK: - Positioning

    private func positionPanel(_ panel: NSPanel, width: CGFloat, height: CGFloat) {
        // Try to position below the status item button
        if let buttonWindow = statusItem?.button?.window {
            let buttonFrame = buttonWindow.frame
            let x = buttonFrame.midX - (width / 2)
            let y = buttonFrame.minY - height - 8
            panel.setFrameOrigin(NSPoint(x: x, y: y))
            return
        }

        // Fallback: center horizontally near top of main screen
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            let visibleFrame = screen.visibleFrame
            let x = screenFrame.midX - (width / 2)
            let y = visibleFrame.maxY - height - 8
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
}
