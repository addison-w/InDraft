import SwiftUI

/// Wabi-sabi ink-line illustration: a flowing pen or brush stroke motif
/// with deliberate asymmetry and sparse elegance.
struct WabiSabiPenIllustration: View {
    var body: some View {
        Canvas { context, size in
            let midX = size.width / 2

            // Main brush body — a long diagonal with gentle curve
            var body = Path()
            body.move(to: CGPoint(x: midX + size.width * 0.2, y: size.height * 0.15))
            body.addQuadCurve(
                to: CGPoint(x: midX - size.width * 0.15, y: size.height * 0.82),
                control: CGPoint(x: midX + size.width * 0.05, y: size.height * 0.5)
            )

            context.stroke(
                body,
                with: .color(Theme.Colors.textPrimary.opacity(0.8)),
                style: StrokeStyle(lineWidth: 1.6, lineCap: .round)
            )

            // Pen nib tip — a short flared stroke at the bottom
            var nib = Path()
            nib.move(to: CGPoint(x: midX - size.width * 0.15, y: size.height * 0.82))
            nib.addQuadCurve(
                to: CGPoint(x: midX - size.width * 0.2, y: size.height * 0.9),
                control: CGPoint(x: midX - size.width * 0.22, y: size.height * 0.85)
            )

            context.stroke(
                nib,
                with: .color(Theme.Colors.textPrimary.opacity(0.7)),
                style: StrokeStyle(lineWidth: 1.8, lineCap: .round)
            )

            // Ink trail — a faint trailing stroke suggesting ink flow
            var trail = Path()
            trail.move(to: CGPoint(x: midX - size.width * 0.2, y: size.height * 0.9))
            trail.addQuadCurve(
                to: CGPoint(x: midX - size.width * 0.06, y: size.height * 0.94),
                control: CGPoint(x: midX - size.width * 0.14, y: size.height * 0.95)
            )

            context.stroke(
                trail,
                with: .color(Theme.Colors.textPrimary.opacity(0.4)),
                style: StrokeStyle(lineWidth: 1.0, lineCap: .round)
            )
        }
        .frame(width: 42, height: Theme.Illustrations.illustrationHeight)
    }
}
