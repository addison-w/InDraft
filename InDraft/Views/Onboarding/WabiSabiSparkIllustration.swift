import SwiftUI

/// Wabi-sabi ink-line illustration: an abstract spark or transformation motif
/// with radiating asymmetric strokes suggesting change and energy.
struct WabiSabiSparkIllustration: View {
    var body: some View {
        Canvas { context, size in
            let midX = size.width / 2
            let midY = size.height / 2

            // Central point — a small filled circle
            var center = Path()
            center.addEllipse(in: CGRect(
                x: midX - 2, y: midY - 2,
                width: 4, height: 4
            ))
            context.fill(
                center,
                with: .color(Theme.Colors.textPrimary.opacity(0.7))
            )

            // Radiating strokes — each with different length, angle, opacity
            let rays: [(start: CGPoint, end: CGPoint, opacity: Double, width: CGFloat)] = [
                // Upward — longest
                (CGPoint(x: midX + 0.5, y: midY - 6),
                 CGPoint(x: midX - 1, y: size.height * 0.14),
                 0.78, 1.5),
                // Upper-right
                (CGPoint(x: midX + 5, y: midY - 4),
                 CGPoint(x: size.width * 0.72, y: size.height * 0.22),
                 0.65, 1.2),
                // Right
                (CGPoint(x: midX + 5, y: midY + 1),
                 CGPoint(x: size.width * 0.78, y: midY + 2),
                 0.7, 1.3),
                // Lower-right — shorter
                (CGPoint(x: midX + 4, y: midY + 5),
                 CGPoint(x: size.width * 0.68, y: size.height * 0.72),
                 0.55, 1.1),
                // Downward
                (CGPoint(x: midX - 0.5, y: midY + 6),
                 CGPoint(x: midX + 1, y: size.height * 0.84),
                 0.72, 1.4),
                // Lower-left
                (CGPoint(x: midX - 5, y: midY + 4),
                 CGPoint(x: size.width * 0.28, y: size.height * 0.7),
                 0.5, 1.0),
                // Left
                (CGPoint(x: midX - 5, y: midY - 1),
                 CGPoint(x: size.width * 0.2, y: midY - 3),
                 0.68, 1.3),
                // Upper-left — faint
                (CGPoint(x: midX - 4, y: midY - 5),
                 CGPoint(x: size.width * 0.3, y: size.height * 0.24),
                 0.48, 1.0),
            ]

            for ray in rays {
                var path = Path()
                path.move(to: ray.start)
                path.addLine(to: ray.end)

                context.stroke(
                    path,
                    with: .color(Theme.Colors.textPrimary.opacity(ray.opacity)),
                    style: StrokeStyle(lineWidth: ray.width, lineCap: .round)
                )
            }
        }
        .frame(width: 44, height: Theme.Illustrations.illustrationHeight)
    }
}
