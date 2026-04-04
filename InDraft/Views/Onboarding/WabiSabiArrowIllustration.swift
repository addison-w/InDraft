import SwiftUI

/// Wabi-sabi ink-line illustration: an upward arrow motif with sparse,
/// asymmetric strokes evoking hand-drawn imperfection.
struct WabiSabiArrowIllustration: View {
    var body: some View {
        Canvas { context, size in
            let midX = size.width / 2
            let bottom = size.height * 0.92
            let top = size.height * 0.15

            // Main vertical stroke — slightly off-center for asymmetry
            var stem = Path()
            stem.move(to: CGPoint(x: midX + 0.5, y: bottom))
            stem.addQuadCurve(
                to: CGPoint(x: midX - 0.3, y: top + size.height * 0.12),
                control: CGPoint(x: midX - 1.2, y: size.height * 0.5)
            )

            context.stroke(
                stem,
                with: .color(Theme.Colors.textPrimary.opacity(0.8)),
                style: StrokeStyle(lineWidth: 1.6, lineCap: .round)
            )

            // Left arrowhead stroke — asymmetric, slightly longer
            var leftWing = Path()
            leftWing.move(to: CGPoint(x: midX - size.width * 0.14, y: top + size.height * 0.28))
            leftWing.addQuadCurve(
                to: CGPoint(x: midX - 0.3, y: top),
                control: CGPoint(x: midX - size.width * 0.08, y: top + size.height * 0.1)
            )

            context.stroke(
                leftWing,
                with: .color(Theme.Colors.textPrimary.opacity(0.75)),
                style: StrokeStyle(lineWidth: 1.4, lineCap: .round)
            )

            // Right arrowhead stroke — shorter, thinner for wabi-sabi imbalance
            var rightWing = Path()
            rightWing.move(to: CGPoint(x: midX + size.width * 0.11, y: top + size.height * 0.25))
            rightWing.addQuadCurve(
                to: CGPoint(x: midX + 0.5, y: top + size.height * 0.03),
                control: CGPoint(x: midX + size.width * 0.06, y: top + size.height * 0.08)
            )

            context.stroke(
                rightWing,
                with: .color(Theme.Colors.textPrimary.opacity(0.7)),
                style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
            )
        }
        .frame(width: 40, height: Theme.Illustrations.illustrationHeight)
    }
}
