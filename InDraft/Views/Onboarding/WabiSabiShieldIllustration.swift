import SwiftUI

/// Wabi-sabi ink-line illustration: an abstract shield motif with organic,
/// asymmetric strokes evoking hand-drawn protection and trust.
struct WabiSabiShieldIllustration: View {
    var body: some View {
        Canvas { context, size in
            let midX = size.width / 2
            let top = size.height * 0.12
            let bottom = size.height * 0.88

            // Left arc of shield — slightly heavier stroke
            var leftArc = Path()
            leftArc.move(to: CGPoint(x: midX - 1, y: top))
            leftArc.addQuadCurve(
                to: CGPoint(x: midX - 0.5, y: bottom),
                control: CGPoint(x: size.width * 0.15, y: size.height * 0.45)
            )

            context.stroke(
                leftArc,
                with: .color(Theme.Colors.textPrimary.opacity(0.78)),
                style: StrokeStyle(lineWidth: 1.6, lineCap: .round)
            )

            // Right arc of shield — thinner, shorter for asymmetry
            var rightArc = Path()
            rightArc.move(to: CGPoint(x: midX + 1.5, y: top + 2))
            rightArc.addQuadCurve(
                to: CGPoint(x: midX + 0.5, y: bottom - 3),
                control: CGPoint(x: size.width * 0.82, y: size.height * 0.42)
            )

            context.stroke(
                rightArc,
                with: .color(Theme.Colors.textPrimary.opacity(0.68)),
                style: StrokeStyle(lineWidth: 1.3, lineCap: .round)
            )

            // Small inner dot — off-center, suggesting a keyhole or focal point
            let dotCenter = CGPoint(x: midX + 1, y: size.height * 0.44)
            var dot = Path()
            dot.addEllipse(in: CGRect(
                x: dotCenter.x - 1.8,
                y: dotCenter.y - 1.8,
                width: 3.6,
                height: 3.6
            ))

            context.fill(
                dot,
                with: .color(Theme.Colors.textPrimary.opacity(0.6))
            )
        }
        .frame(width: 40, height: Theme.Illustrations.illustrationHeight)
    }
}
