import SwiftUI
import Hugeicons

/// A single close button matching the app's warm minimal aesthetic.
/// This app lives in the menu bar (no dock icon), so minimize/zoom are unnecessary.
/// Automatically discovers its hosting window — no need to pass a window reference.
struct WindowCloseButton: View {
    @State private var isHovered = false
    @State private var hostWindow: NSWindow?

    var body: some View {
        Button {
            hostWindow?.close()
        } label: {
            ZStack {
                Circle()
                    .fill(Theme.Colors.windowControlClose)
                    .frame(width: 14, height: 14)

                if isHovered {
                    AppIcon.close.image()
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8)
                        .foregroundColor(Theme.Colors.windowControlIcon)
                        .transition(.opacity.animation(.easeInOut(duration: 0.1)))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
        .accessibilityHint("Press to close this window")
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
        .background(WindowAccessor { hostWindow = $0 })
    }
}

// MARK: - Window Accessor

/// Discovers the NSWindow hosting this SwiftUI view hierarchy.
private struct WindowAccessor: NSViewRepresentable {
    let onWindow: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            onWindow(view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            onWindow(nsView.window)
        }
    }
}

// MARK: - Window Drag Area

/// NSView-based drag area so the custom titlebar remains draggable
struct WindowDragArea: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = DraggableView()
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private class DraggableView: NSView {
    override public var mouseDownCanMoveWindow: Bool { true }

    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}
